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

alias ll="ls -laGH"
alias gl='git log --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) <%an>%Creset'\'' --abbrev-commit --date=iso'
alias gs="git status"
alias dpa="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}'"
alias dli="docker image ls -a --format table"
alias gfo='git add -A; git commit -m "gfo"; git push'

# Completion

autoload -Uz compinit && compinit

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

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
source $(brew --prefix)/etc/bash_completion.d/az

# Private

if [ -f $HOME/.zshrc_private ]; then
    source $HOME/.zshrc_private
fi