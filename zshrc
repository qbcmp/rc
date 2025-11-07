# Historymaxxing

HISTFILE=${HISTFILE:-"$HOME/.zsh_history"}
HISTSIZE=1000000
SAVEHIST=1000000

setopt APPEND_HISTORY           # keep existing history instead of overwriting
setopt INC_APPEND_HISTORY       # write each command immediately
setopt INC_APPEND_HISTORY_TIME  # persist timing metadata with each command
setopt SHARE_HISTORY            # sync history across parallel shells
setopt EXTENDED_HISTORY         # record timestamps and durations
setopt HIST_FCNTL_LOCK          # avoid clobbering when multiple shells write
setopt HIST_IGNORE_SPACE        # allow intentional private commands to be hidden
setopt HIST_REDUCE_BLANKS       # trim redundant whitespace
setopt HIST_VERIFY              # let me edit recalled commands before running

HIST_STAMPS="yyyy-mm-dd HH:MM:SS"

# Custom things

if [ -f $HOME/bin/qbcmp_prompt_zsh ]; then
    source $HOME/bin/qbcmp_prompt_zsh
fi

# Aliases

if [[ "$(uname)" == "Darwin" ]]; then
  alias ll='ls -laGH'
elif [[ "$(uname)" == "Linux" ]]; then
    alias ll='ls -la --group-directories-first --human-readable'
fi

alias k="kubectl"
alias gl='git log --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) <%an>%Creset'\'' --abbrev-commit --date=iso'
alias gs="git status"
alias dpa="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}'"
alias dli="docker image ls -a --format table"
alias gfo="git add -A; git commit -m 'gfo'; git push"
alias hla="helm list all"
alias kge="kubectl get events --sort-by='\''.metadata.creationTimeStamp'\'''"


t() { tree -aC -I '.git' --dirsfirst "$@" | less -FRNX; }
alias t1='t -L 1'
alias t2='t -L 2'
alias t3='t -L 3'


# Completion

autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:commands' description 'yes'
zstyle ':completion:*:*:*:*:commands' list-colors ''

if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

if command -v helm &>/dev/null; then
  source <(helm completion zsh)
fi

if command -v docker &>/dev/null; then
  source <(docker completion zsh)
fi

if command -v kind &>/dev/null; then
  source <(kind completion zsh)
fi

if command -v terraform &>/dev/null; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

if command -v az &>/dev/null; then
  source $(brew --prefix)/etc/bash_completion.d/az
fi

# Private

if [ -f $HOME/.zshrc_private ]; then
    source $HOME/.zshrc_private
fi