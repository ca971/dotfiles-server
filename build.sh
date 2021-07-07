#!/usr/bin/env bash

set -eo pipefail

basedir="$HOME/.dotfiles"
bindir="$HOME/bin"
repourl="https://github.com/ca971/dotfiles-server.git"

function symlink() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ]; then
    if [ -L "$dest" ]; then
      if [ ! -e "$dest" ]; then
        echo "Removing broken symlink at $dest"
        rm "$dest"
      else
        # Already symlinked -- I'll assume correctly.
        return 0
      fi
    else
      # Rename files with a ".old" extension.
      echo "$dest already exists, renaming to $dest.old"
      backup="$dest.old"
      if [ -e "$backup" ]; then
        echo "Error: "$backup" already exists. Please delete or rename it."
        exit 1
      fi
      mv "$dest" "$backup"
    fi
  fi
  ln -sf "$src" "$dest"
}

if [ -d "$basedir/.git" ]; then
  echo "Updating dotfiles using existing git..."
  cd "$basedir"
  git pull --quiet --rebase origin main || exit 1
else
  echo "Checking out dotfiles using git..."
  rm -rf "$basedir"
  git clone --quiet --depth=1 "$repourl" "$basedir"
fi

cd "$basedir"

echo "Updating common Zsh completions..."
rm -rf .zsh-completions ~/.zcompdump
git clone --quiet --depth=1 https://github.com/zsh-users/zsh-completions .zsh-completions

files=(
  $HOME/.bashrc
  $HOME/.zshrc
)

for f in ${files[@]}
do
  [ -e "$f" ] && mv "$f" "$f.old"
done
unset f

echo "Creating symlinks..."
for item in .* ; do
  case "$item" in
    .|..|.git)
      continue
      ;;
    *)
      symlink "$basedir/$item" "$HOME/$item"
      ;;
  esac
done
symlink "$basedir/.vim/.vimrc" "$HOME/.vimrc"
#symlink "$basedir/.vim/gvimrc" "$HOME/.gvimrc"


echo "Adding executables to ~/bin/..."
mkdir -p "$bindir"
for item in bin/* ; do
  symlink "$basedir/$item" "$bindir/$(basename $item)"
done

#if which tmux >/dev/null 2>&1 ; then
#  echo "Setting up tmux..."
#  tpm="$HOME/.tmux/plugins/tpm"
#  if [ -e "$tpm" ]; then
#    pushd "$tpm" >/dev/null
#    git pull -q origin master
#    popd >/dev/null
#  else
#    git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
#  fi
#  $tpm/scripts/install_plugins.sh >/dev/null
#  $tpm/scripts/clean_plugins.sh >/dev/null
#  $tpm/scripts/update_plugin.sh >/dev/null
#else
#  echo "Skipping tmux setup because tmux isn't installed."
#fi

postinstall="$HOME/.postinstall"
if [ -e "$postinstall" ]; then
  echo "Running post-install..."
  . "$postinstall"
else
  echo "No post install script found. Optionally create one at $postinstall"
fi

if [ ! -e "$HOME/.zshlocal" ]; then
  color=$((22 + RANDOM % 209))
  echo -e "# If you want a different color, run ~/bin/c.256-colors and replace $color below:\ncolorprompt \"38;5;$color\"" >"$HOME/.zshlocal"
  echo "Chose a random prompt color. Edit $HOME/.zshlocal to change it."
fi

echo "Done."
