# Historymaxxing ---------------------------------------------------------------

HISTFILE=${HISTFILE:-"$HOME/.zsh_history"}
HISTSIZE=1000000
SAVEHIST=1000000
HIST_STAMPS="yyyy-mm-dd HH:MM:SS"

setopt APPEND_HISTORY           # keep existing history instead of overwriting
setopt INC_APPEND_HISTORY       # write each command immediately
setopt INC_APPEND_HISTORY_TIME  # persist timing metadata with each command
setopt SHARE_HISTORY            # sync history across parallel shells
setopt EXTENDED_HISTORY         # record timestamps and durations
setopt HIST_FCNTL_LOCK          # avoid clobbering when multiple shells write
setopt HIST_IGNORE_SPACE        # allow intentional private commands to be hidden
setopt HIST_REDUCE_BLANKS       # trim redundant whitespace
setopt HIST_VERIFY              # let me edit recalled commands before running

# Plugins ----------------------------------------------------------------------

if [[ -d $HOME/.zsh/zsh-z ]]; then
  source ~/.zsh/zsh-z/zsh-z.plugin.zsh
fi

if [[ -d $HOME/.zsh/zsh-autosuggestions ]]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
fi

# Completions ------------------------------------------------------------------
# Cache completions and initialize compinit lazily.

typeset -g ZSH_COMP_DIR="${ZSH_COMP_DIR:-$HOME/.zsh/completions}"
mkdir -p "$ZSH_COMP_DIR"

typeset -gU fpath
fpath=("$ZSH_COMP_DIR" $fpath)

typeset -g ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
mkdir -p "$ZSH_CACHE_DIR"
typeset -g ZSH_COMPDUMP="${ZSH_COMPDUMP:-$ZSH_CACHE_DIR/.zcompdump}"

typeset -ga ZSH_COMPLETION_COMMANDS
if (( ${#ZSH_COMPLETION_COMMANDS[@]} == 0 )); then
  ZSH_COMPLETION_COMMANDS=(kubectl helm docker)
fi
typeset -g ZSH_COMPLETION_STAMP="${ZSH_COMPLETION_STAMP:-$ZSH_COMP_DIR/.last_refresh}"
typeset -gi ZSH_COMPLETION_CACHE_INTERVAL
ZSH_COMPLETION_CACHE_INTERVAL=${ZSH_COMPLETION_CACHE_INTERVAL:-43200}

_zsh_cache_completions() {
  emulate -L zsh
  local cmd cache_file binary_path
  for cmd in "${ZSH_COMPLETION_COMMANDS[@]}"; do
    if (( $+commands[$cmd] )); then
      cache_file="$ZSH_COMP_DIR/_$cmd"
      binary_path="$(whence -p "$cmd")"
      if [[ -n $binary_path && ( ! -f $cache_file || $binary_path -nt $cache_file ) ]]; then
        "$cmd" completion zsh >| "$cache_file" 2>/dev/null
      fi
    fi
  done
}

_zsh_ensure_completion_cache() {
  emulate -L zsh
  local stamp=0 cmd cache_file needs_bootstrap=0
  if [[ -r $ZSH_COMPLETION_STAMP ]]; then
    read -r stamp < "$ZSH_COMPLETION_STAMP"
  fi
  for cmd in "${ZSH_COMPLETION_COMMANDS[@]}"; do
    if (( $+commands[$cmd] )); then
      cache_file="$ZSH_COMP_DIR/_$cmd"
      if [[ ! -f $cache_file ]]; then
        needs_bootstrap=1
        break
      fi
    fi
  done
  if (( needs_bootstrap )); then
    _zsh_cache_completions
    print -r -- $EPOCHSECONDS >| "$ZSH_COMPLETION_STAMP"
  elif (( EPOCHSECONDS - stamp > ZSH_COMPLETION_CACHE_INTERVAL )); then
    (
      _zsh_cache_completions
      print -r -- $EPOCHSECONDS >| "$ZSH_COMPLETION_STAMP"
    ) &!
  fi
}

_zsh_ensure_completion_cache

# Enable menu selection for completions so you can navigate with arrow keys.
zstyle ':completion:*' menu select

# Automatically select the first completion entry.
zstyle ':completion:*' auto-select true

# Make completion case-insensitive.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Detailed List of Files and Folders
zstyle ':completion:*' file-list all

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'  # Yellow description
zstyle ':completion:*' group-name ''                         # Group results nicely

autoload -Uz compinit
compinit -C -d "$ZSH_COMPDUMP"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Source

export PATH=$PATH:$HOME/bin


files=(
  "$HOME/.private"
  "$HOME/bin/termbg"
  "$HOME/bin/qbcmp_prompt_zsh"
  "$HOME/.aliases"
)

for f in "${files[@]}"; do
  if [[ -f $f ]]; then
    source "$f"
  fi
done
