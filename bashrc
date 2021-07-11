# If ZSH : Quit now !
# =============================================================================
if [[ -n "$ZSH_VERSION" ]]; then
  return 1 2> /dev/null || exit 1;
fi;

# Source variables, aliases, aliases
# =============================================================================
for file in $HOME/.{exports,functions,localrc,git_prompt,aliases}; do
  [ -r "$file" ] && [ -f "$file" ] && . "$file";
done;
unset file;

# Completion
# =============================================================================
# brew install bash-completion
if is_osx && [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# Dircolors
# =============================================================================
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

# Source .git_prompt.sh, if exists !
# =============================================================================
#if [ -f "$HOME/.git_prompt.sh" ]; then
#  . $HOME/.git_prompt.sh;
#  PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
#fi

# Fasd
# =============================================================================
if command -v fasd 2>/dev/null; then
  fasd_cache="$HOME/.cache/.fasd-init-bash"

  if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
  fi

  source "$fasd_cache"
  unset fasd_cache
fi

# Fzf
# =============================================================================
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# Local config
# =============================================================================
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# vim: set ft=bash:
