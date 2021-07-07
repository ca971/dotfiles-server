if [[ -n "$BASH_VERSION" ]]; then
  return 1 2> /dev/null || exit 1;
fi;

# Variables
# ============================================================================
#ZSH_THEME="oxide";
ZSH_THEME="spaceship";
SPACESHIP_BATTERY_SHOW=false
CASE_SENSITIVE="true"   # Case-sensitive completion
DISABLE_CORRECTION="true" # Disable auto-correct built into Zsh
ZSH="${ZSH:-"$HOME/.oh-my-zsh"}"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Automatically remove duplicates from these arrays
if [ -n "$ZSH_VERSION" ]; then
  typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH
fi

# Oh-my-zsh
# ============================================================================
plugins=(
  osx
  sudo                        # hitting ESC twice puts sudo in front of the current command, or the last one if the command line is emy
  vi-mode
  vscode                      # makes interaction between the command line and the code editor easier
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  git-open
  #zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# Colors
# ============================================================================
autoload -U colors && colors

# Fix for making docker plugin work
# ============================================================================
autoload -U compinit && compinit

# Help
# ============================================================================
# fast man page access with <esc-h>
autoload run-help

# Source files
# ============================================================================
for file in $HOME/.{exports,functions,localrc,git_prompt,aliases}; do
  [ -r "$file" ] && [ -f "$file" ] && . "$file";
done;
unset file;

# Key bindings
# ============================================================================
bindkey -e # Use emacs-like key bindings by default:

# [Ctrl-r] - Search backward incrementally for a specified string. The string
# may begin with ^ to anchor the search to the beginning of the line.
bindkey '^r' history-incremental-search-backward

# History
# ============================================================================
setopt append_history
setopt inc_append_history # Appends every command to the history file once it is executed
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt share_history  # Reloads the history whenever you use it

# Next bindings are used j k to cycle through history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Completion
# ============================================================================
# Load and initialize completion
autoload -Uz compinit && compinit
autoload bashcompinit && bashcompinit

# https://vimeo.com/108223630
complete -F _tmux_complete_session tm

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.zsh
fpath=(~/.zsh $fpath)

zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# autocompletion with an arrow-key driven interface
zstyle ':completion:*:*:*:*:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        man mysql shutdown sync '_*'

zstyle '*' single-ignored show

# Automatically update PATH entries
zstyle ':completion:*' rehash true

# Keep directories and files separated
zstyle ':completion:*' list-dirs-first true

# Dircolors
# ----------------------------------------------------------------------------
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

# Fasd
# ----------------------------------------------------------------------------
fasd_cache="$HOME/.cache/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# Fzf
# ----------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local
# ----------------------------------------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

### Added by Zinit's installer
# ----------------------------------------------------------------------------
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# >>>> Vagrant command completion (start)
if command -v vagrant > /dev/null; then
  fpath=(/opt/vagrant/embedded/gems/$VAGRANT_VERSION/gems/vagrant-$VAGRANT_VERSION/contrib/zsh $fpath)
  compinit
fi
# <<<<  Vagrant command completion (end)
