alias vim="nvim ."

# this loads the autocomplete engine, will check out later
autoload -U compinit; compinit

[ -f ~/.zsh_prompt ] && source ~/.zsh_prompt
[ -f ~/Devel/fzf-tab/fzf-tab.plugin.zsh ] && source ~/Devel/fzf-tab/fzf-tab.plugin.zsh

# autocompletion for dotnet
_dotnet_completion() {
  local -a completions=("${(@f)$(dotnet complete "${words}")}")

  compadd -a completions
}

compdef _dotnet_completion dotnet
