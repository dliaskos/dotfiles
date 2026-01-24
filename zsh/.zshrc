source ~/.zsh_env
source ~/.zsh_alias
source ~/.zsh_prompt

# this loads the autocomplete engine, will check out later
autoload -U compinit; compinit

# fzf-tab
source ~/Devel/fzf-tab/fzf-tab.plugin.zsh

# autocompletion for dotnet
_dotnet_completion() {
  local -a completions=("${(@f)$(dotnet complete "${words}")}")
  
  compadd -a completions
}

compdef _dotnet_completion dotnet
