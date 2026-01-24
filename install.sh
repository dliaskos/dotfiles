#!/usr/bin/env zsh

STOW_PACKAGES=(
    "nvim"
    "ghostty"
    "zsh"
)

OPTIONAL_DEPS=(
    "rg"
)

DRY_RUN=true

if [[ "$1" == "--apply" ]]; then
    DRY_RUN=false
fi

if ! command -v stow &> /dev/null; then
    echo "Error: stow is not installed. Please install it first."
    exit 1
fi

if $DRY_RUN; then
    echo "No changes will be made. Use './install.sh --apply' to execute."
    echo ""
    STOW_CMD="stow -n -v --adopt -t $HOME --ignore='\.DS_Store'" 
else
    STOW_CMD="stow --adopt -t $HOME --ignore='\.DS_Store'"
fi

for pkg in "${STOW_PACKAGES[@]}"; do
    if [ ! -d "$pkg" ]; then
        echo "Skipping $pkg: Directory not found."
        continue
    fi

    echo "Processing $pkg..."
    eval $STOW_CMD "$pkg"
done

echo ""
echo "Checking optional dependencies..."

for tool in "${OPTIONAL_DEPS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "  [MISSING] $tool"
    else
        echo "  [OK]      $tool"
    fi
done

# 6. Final Prompt
echo ""
if $DRY_RUN; then
    echo "Dry run complete. If the output looks correct, run:"
    echo "  ./install.sh --apply"
else
    echo "Done."
    echo "Check 'git status' now. The --adopt flag may have modified your repo files."
fi
