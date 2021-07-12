#!/bin/sh

set -e

# Theme and Plugings for Oh-my-zsh
THEME=powerlevel10k/powerlevel10k
PLUGINS=""
ZSHRC_APPEND=""

# Install github dotfiles
BASE_DIR="$HOME/.dotfiles"
BIN_DIR="$HOME/bin"
REPO_URL="https://github.com/ca971/dotfiles-server.git"

while getopts ":t:p:a:" opt; do

  case ${opt} in

    t)  THEME=$OPTARG
        ;;

    p)  PLUGINS="${PLUGINS}$OPTARG "
        ;;

    a)  ZSHRC_APPEND="$ZSHRC_APPEND\n$OPTARG"
        ;;

    \?) echo "Invalid option: $OPTARG" 1>&2
        ;;

    :)  echo "Invalid option: $OPTARG requires an argument" 1>&2
        ;;

  esac

done

shift $((OPTIND -1))

echo
echo "Installing Oh-My-Zsh with:"
echo "  THEME   = $THEME"
echo "  PLUGINS = $PLUGINS"
echo

check_dist() {
  (
    . /etc/os-release
    echo $ID
  )
}

check_version() {
  (
    . /etc/os-release
    echo $VERSION_ID
  )
}

install_dependencies() {
  DIST=`check_dist`
  VERSION=`check_version`
  echo "###### Installing dependencies for $DIST"

  if [ "`id -u`" = "0" ]; then
    Sudo=''
  elif which sudo; then
    Sudo='sudo'
  else
    echo "WARNING: 'sudo' command not found. Skipping the installation of dependencies. "
    echo "If this fails, you need to do one of these options:"
    echo "   1) Install 'sudo' before calling this script"
    echo "OR"
    echo "   2) Install the required dependencies: git curl zsh"
    return
  fi

  case $DIST in

    alpine)
      $Sudo apk add --update --no-cache git curl zsh
      ;;

    centos | amzn)
      $Sudo yum update -y
      $Sudo yum install -y git curl
      $Sudo yum install -y ncurses-compat-libs # this is required for AMZN Linux (ref: https://github.com/emqx/emqx/issues/2503) 
      $Sudo curl http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm > zsh-5.1-1.gf.el7.x86_64.rpm
      $Sudo rpm -i zsh-5.1-1.gf.el7.x86_64.rpm
      $Sudo rm zsh-5.1-1.gf.el7.x86_64.rpm
      ;;

    *)
      $Sudo apt-get update && apt-get upgrade -y
      $Sudo apt-get install -y --no-install-recommends \
        apt-utils \
        autoconf \
        automake \
        bash-completion \
        bind9-host \
        bsdmainutils \
        build-essential \
        ca-certificates \
        coreutils \
        cowsay \
        dfc \
        dirmngr \
        exa \
        gnupg \
        gnupg2 \
        curl \
        fasd \
        file \
        fontconfig \
        git-core \
        htop \
        hwinfo \
        jq \
        libbz2-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libnss3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        locales \
        localepurge \
        llvm \
        lsof \
        make \
        most \
        man \
        neofetch \
        netcat \
        nmap \
        net-tools \
        neovim \
        openssh-server \
        p7zip-full \
        perl \
        procps \
        python \
        python3-pip \
        python3-venv \
        rar \
        ruby \
        ruby-dev \
        scala \
        sl \
        socat \
        software-properties-common \
        ssh \
        strace \
        sysstat \
        tcpdump \
        tk-dev \
        tmux \
        unzip \
        unrar \
        util-linux \
        vim \
        w3m \
        whois \
        xz-utils \
        zip \
        zlib1g-dev \
        zsh
      if [ "$VERSION" != "14.04" ]; then
        $Sudo apt-get -y install locales-all
      fi
      $Sudo echo "LANG=fr_FR.UTF-8" >/etc/default/locale
      $Sudo locale-gen --purge fr_FR.UTF-8
      $Sudo update-locale LANG=fr_FR.UTF-8
      $Sudo echo "Europe/Paris" > /etc/timezone

  esac
}

zshrc_template() {
  _HOME=$1; 
  _THEME=$2; shift; shift
  _PLUGINS=$*;

  cat <<EOM
export LANG='fr_FR.UTF-8'
export LANGUAGE='fr_FR:en'
#export LC_ALL='fr_FR.UTF-8'
export TERM=xterm

##### Zsh/Oh-my-Zsh Configuration
export ZSH="$_HOME/.oh-my-zsh"

# Automatically remove duplicates from these arrays
if [ -n "$ZSH_VERSION" ]; then
  typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH
fi

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

EOM
  printf "$ZSHRC_APPEND"
  printf "\nsource \$ZSH/oh-my-zsh.sh\n"
}

powerline10k_config() {
  cat <<EOM
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_CROSS=true
EOM
}

symlink() {
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

# Create /usr/local/share/zsh-syntax-highlighting/highlighters
mkdir -p /usr/local/share/zsh-syntax-highlighting/highlighters


# Install all dependencies
install_dependencies

# Switch into tmp directory
cd /tmp

# Install On-My-Zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
fi

# Generate plugin list
plugin_list=""
for plugin in $PLUGINS; do
  if [ "`echo $plugin | grep -E '^http.*'`" != "" ]; then
    plugin_name=`basename $plugin`
    git clone $plugin $HOME/.oh-my-zsh/custom/plugins/$plugin_name
  else
    plugin_name=$plugin
  fi
  plugin_list="${plugin_list}$plugin_name "
done

# Handle themes
if [ "`echo $THEME | grep -E '^http.*'`" != "" ]; then
  theme_repo=`basename $THEME`
  THEME_DIR="$HOME/.oh-my-zsh/custom/themes/$theme_repo"
  git clone $THEME $THEME_DIR
  theme_name=`cd $THEME_DIR; ls *.zsh-theme | head -1` 
  theme_name="${theme_name%.zsh-theme}"
  THEME="$theme_repo/$theme_name"
fi

# Generate .zshrc
zshrc_template "$HOME" "$THEME" "$plugin_list" > $HOME/.zshrc

# Install powerlevel10k if no other theme was specified
if [ "$THEME" = "powerlevel10k/powerlevel10k" ]; then
  git clone https://github.com/romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k
  powerline10k_config >> $HOME/.zshrc
fi

# Istall pyenv, nvm, rvm, linuxbrew, ... in home directory
cd ~

# Clone github dotfiles into $BASE_DIR
if [ -d "$BASE_DIR/.git" ]; then
  echo "Updating dotfiles using existing git..."
  cd "$BASE_DIR"
  git pull --quiet --rebase origin main || exit 1
else
  echo "Checking out dotfiles using git..."
  rm -rf "$BASE_DIR"
  git clone --quiet --depth=1 "$REPO_URL" "$BASE_DIR"
fi

# Make config, local, cache, fonts directories
test -d "~/.config" || mkdir ~/.config
test -d "~/.local" || mkdir ~/.local
test -d "~/.cache" || mkdir ~/.cache
test -d "~/.fonts" || mkdir ~/.fonts

# Install FiraCode nerdfonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
fc-cache -fv
rm FiraCode.zip

# Switch into $BASE_DIR
cd "$BASE_DIR"

# "Updating common Zsh completions..."
rm -rf .zsh-completions ~/.zcompdump
git clone --quiet --depth=1 https://github.com/zsh-users/zsh-completions .zsh-completions

# Create simlinks to $HOME directory
echo "Creating symlinks..."
for item in .* ; do
  case "$item" in
    .|..|.git)
      continue
      ;;
    *)
      symlink "$BASE_DIR/$item" "$HOME/$item"
      ;;
  esac
done

symlink "$BASE_DIR/.vim/.vimrc" "$HOME/.vimrc"
symlink "$BASE_DIR/.vim" "$HOME/.config/nvim"

test -e "$BASE_DIR/.vim/.vimrc_local" && symlink "$BASE_DIR/.vim/.vimrc_local" "$HOME/.vimrc_local"
test -e "$BASE_DIR/.vim/.vimrc_before" && symlink "$BASE_DIR/.vim/.vimrc_before" "$HOME/.vimrc_before"
test -e "$BASE_DIR/.vim/.vimrc_bundles" && symlink "$BASE_DIR/.vim/.vimrc_bundles" "$HOME/.vimrc_bundles"
test -e "$BASE_DIR/.vim/.gvimrc" && symlink "$BASE_DIR/.vim/.gvimrc" "$HOME/.gvimrc"

cat "$BASE_DIR/bashrc" > $HOME/.bashrc
cat "$BASE_DIR/zshrc" >> $HOME/.zshrc

# Symlink dotfiles/bin to $HOME/bin
echo "Adding executables to ~/bin/..."
mkdir -p "$BIN_DIR"
for item in bin/* ; do
  symlink "$BASE_DIR/$item" "$BIN_DIR/$(basename $item)"
done


# Install tmux plugin manager
if which tmux >/dev/null 2>&1 ; then
  echo "Setting up tmux..."
  tpm="$HOME/.tmux/plugins/tpm"
  if [ -e "$tpm" ]; then
    pushd "$tpm" >/dev/null
    git pull -q origin master
    popd >/dev/null
  else
    git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  $tpm/scripts/install_plugins.sh >/dev/null
  $tpm/scripts/clean_plugins.sh >/dev/null
  $tpm/scripts/update_plugin.sh >/dev/null
else
  echo "Skipping tmux setup because tmux isn't installed."
fi

# Post install if necessary
postinstall="$HOME/.postinstall"
if [ -e "$postinstall" ]; then
  echo "Running post-install..."
  . "$postinstall"
else
  echo "No post install script found. Optionally create one at $postinstall"
fi

# Chose your locales preferences in zshlocal
if [ ! -e "$HOME/.zshlocal" ]; then
  color=$((22 + RANDOM % 209))
  echo -e "# If you want a different color, run ~/bin/c.256-colors and replace $color below:\ncolorprompt \"38;5;$color\"" >"$HOME/.zshlocal"
  echo "Chose a random prompt color. Edit $HOME/.zshlocal to change it."
fi

echo "All done."
