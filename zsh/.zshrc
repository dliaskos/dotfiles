setopt PROMPT_SUBST

setopt INC_APPEND_HISTORY    # write commands to history file immediately
setopt SHARE_HISTORY         # merge history from other sessions
setopt HIST_IGNORE_DUPS      # ignore duplicate commands
setopt HIST_REDUCE_BLANKS    # remove blank lines
HISTFILE=~/.zsh_history      # ensure history file location
HISTSIZE=5000                # in-memory history
SAVEHIST=5000                # history file size

# this loads the autocomplete engine, will check out later
autoload -U compinit; compinit

source <(fzf --zsh)

[ -f ~/.zsh_env ] && source ~/.zsh_env
[ -f ~/.zsh_prompt ] && source ~/.zsh_prompt
[ -f ~/Devel/fzf-tab/fzf-tab.plugin.zsh ] && source ~/Devel/fzf-tab/fzf-tab.plugin.zsh
[ -f /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh ] && source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

# autocompletion for dotnet
_dotnet_completion() {
  local -a completions=("${(@f)$(dotnet complete "${words}")}")

  compadd -a completions
}

compdef _dotnet_completion dotnet
