#!/usr/bin/env zsh
#
# Build netcoredbg from source for macOS arm64.
#
# Samsung ships no native macOS arm64 release, so we build upstream ourselves and
# install the artifacts nvim-dap needs into a flat prefix (see lua/plugins/dap.lua).
#
#   ./scripts/build-netcoredbg.sh            Incremental build + install.
#   ./scripts/build-netcoredbg.sh --clean    Wipe build artifacts first.
#
# Overridable via the environment:
#   NETCOREDBG_SRC      Source checkout       (default: ~/devel/netcoredbg)
#   NETCOREDBG_PREFIX   Install destination   (default: ~/.local/share/netcoredbg)
#   DOTNET_DIR          .NET SDK root         (default: /usr/local/share/dotnet)

set -e

NETCOREDBG_SRC="${NETCOREDBG_SRC:-$HOME/devel/netcoredbg}"
NETCOREDBG_PREFIX="${NETCOREDBG_PREFIX:-$HOME/.local/share/netcoredbg}"
DOTNET_DIR="${DOTNET_DIR:-/usr/local/share/dotnet}"

BUILD_DIR="$NETCOREDBG_SRC/build"

# The managed part is built by 'dotnet publish', which leaves persistent daemons
# behind -- the Roslyn compiler server and MSBuild's reused nodes. They get
# reparented to init and keep this script's inherited stdout/stderr open for about
# ten minutes, so anything reading our output (a pipe, a CI log collector) blocks
# long after the build itself has finished. Disable both.
export MSBUILDDISABLENODEREUSE=1
export UseSharedCompilation=false
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1

# The complete set of install() rules in src/CMakeLists.txt. netcoredbg dlopen's
# libdbgshim.dylib from its own directory, so this flat layout is self-contained.
ARTIFACTS=(
    "netcoredbg"
    "libdbgshim.dylib"
    "ManagedPart.dll"
    "Microsoft.CodeAnalysis.dll"
    "Microsoft.CodeAnalysis.CSharp.dll"
    "Microsoft.CodeAnalysis.Scripting.dll"
    "Microsoft.CodeAnalysis.CSharp.Scripting.dll"
)

CLEAN=false
if [[ "${1:-}" == "--clean" ]]; then
    CLEAN=true
fi

# 1. Prerequisites
echo "Checking prerequisites..."

MISSING=false

for tool in cmake clang clang++ git; do
    if command -v "$tool" &> /dev/null; then
        echo "  [OK]      $tool"
    else
        echo "  [MISSING] $tool"
        MISSING=true
    fi
done

if [ -x "$DOTNET_DIR/dotnet" ] && [ -d "$DOTNET_DIR/shared/Microsoft.NETCore.App" ]; then
    echo "  [OK]      dotnet ($DOTNET_DIR)"
else
    echo "  [MISSING] dotnet at $DOTNET_DIR"
    MISSING=true
fi

if [ ! -d "$NETCOREDBG_SRC" ]; then
    echo "  [MISSING] sources at $NETCOREDBG_SRC"
    echo "            git clone https://github.com/Samsung/netcoredbg $NETCOREDBG_SRC"
    MISSING=true
fi

if $MISSING; then
    echo ""
    echo "Install the missing prerequisites first, e.g.:"
    echo "  brew install cmake"
    echo "  https://dotnet.microsoft.com/download"
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo ""
    echo "Warning: this script targets arm64, but uname -m reports $(uname -m)."
    echo "The build system has no cross-arch support; it follows the host only."
fi

# 2. Configure
if $CLEAN; then
    echo ""
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR" "$NETCOREDBG_SRC/src/debug/netcoredbg/bin" "$NETCOREDBG_SRC/bin"
fi

mkdir -p "$BUILD_DIR"

CMAKE_ARGS=(
    # Every CMakeLists here declares cmake_minimum_required(VERSION 3.5), which
    # CMake 4.x refuses outright. Without this the configure step dies instantly.
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_BUILD_TYPE=Release"
    # Used as a literal, flat DESTINATION -- everything lands directly in here.
    "-DCMAKE_INSTALL_PREFIX=$NETCOREDBG_PREFIX"
    # Reuse the installed SDK instead of downloading a second one into .dotnet/.
    "-DDOTNET_DIR=$DOTNET_DIR"
)

# On the first run fetchdeps.cmake shallow-clones dotnet/runtime into .coreclr for
# its PAL and cordebug headers. Pin it afterwards so re-configuring stays offline.
CORECLR_DIR="$NETCOREDBG_SRC/.coreclr/src/coreclr"
if [ -d "$CORECLR_DIR/pal" ]; then
    echo ""
    echo "Reusing CoreCLR sources at $CORECLR_DIR"
    CMAKE_ARGS+=("-DCORECLR_DIR=$CORECLR_DIR")
else
    echo ""
    echo "CoreCLR sources not present; cmake will clone dotnet/runtime (~1-2 GB, one time)."
fi

echo ""
echo "Configuring..."
cd "$BUILD_DIR"
CC=clang CXX=clang++ cmake "$NETCOREDBG_SRC" "${CMAKE_ARGS[@]}"

# 3. Build and install
echo ""
echo "Building..."
make -j"$(sysctl -n hw.ncpu)"

echo ""
echo "Installing to $NETCOREDBG_PREFIX..."
make install

# 4. Verify
echo ""
echo "Verifying artifacts..."

FAILED=false

for artifact in "${ARTIFACTS[@]}"; do
    if [ -f "$NETCOREDBG_PREFIX/$artifact" ]; then
        echo "  [OK]      $artifact"
    else
        echo "  [MISSING] $artifact"
        FAILED=true
    fi
done

# The managed publish is the fragile step; if it produced nothing we want to know
# here rather than when nvim-dap fails to start a session.
if $FAILED; then
    echo ""
    echo "Error: the build did not produce every required artifact."
    echo "The 'dotnet publish' of src/managed/ManagedPart.csproj is the usual culprit."
    exit 1
fi

for native in "netcoredbg" "libdbgshim.dylib"; do
    ARCH_INFO="$(lipo -info "$NETCOREDBG_PREFIX/$native" 2>&1)"
    case "$ARCH_INFO" in
        *arm64*) echo "  [OK]      $native is arm64" ;;
        *)
            echo "  [FAIL]    $native: $ARCH_INFO"
            FAILED=true
            ;;
    esac
done

if $FAILED; then
    echo ""
    echo "Error: built binaries are not arm64."
    exit 1
fi

echo ""
"$NETCOREDBG_PREFIX/netcoredbg" --version
echo ""
echo "Done. Point nvim-dap at $NETCOREDBG_PREFIX/netcoredbg"
