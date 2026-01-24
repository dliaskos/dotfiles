source ~/.zsh_prompt

# aliases
alias vi="nvim"
alias vim="nvim"

# environment variables
export EDITOR=nvim

autoload -U compinit; compinit

# fzf-tab
source ~/Devel/fzf-tab/fzf-tab.plugin.zsh

# autocompletion for dotnet
_dotnet_completion() {
  local -a completions=("${(@f)$(dotnet complete "${words}")}")
  
  compadd -a completions
}

compdef _dotnet_completion dotnet
