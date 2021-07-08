FROM debian:latest
MAINTAINER ca971

LABEL Description="Debian For Dev"

ARG DEBIAN_FRONTEND=noninteractive

# DOTFILES Directory
ENV DOTFILES_DIR=dotfiles

# Non privilegged User
ARG USER_NAME="ca971"
ARG USER_PASSWORD="p@$$w0d"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD

# Container image version
ENV CONTAINER_IMAGE_VER=v1.0.0

# Locales environment
ENV LANG=fr_FR.UTF-8

# Default terminal
ENV TERM xterm

# Pyenv and Python
ENV PYENV_ROOT $HOME/.pyenv
ENV PYTHONDONTWRITEBYTECODE true
ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV true
ENV PYTHON_VERSION 3.9.6
ENV PYTHON_VERSION_FILE="Python-$PYTHON_VERSION.tgz"

# Nvm environment variables
ENV NVM_DIR $HOME/.nvm
ENV NODE_VERSION node
ENV NODE_LTS_VERSION 14.17.3

# Zsh and Oh-My-Zsh
ENV ZSH_THEME spaceship
ENV ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# Display environment variables
RUN echo $USER_NAME
RUN echo $USER_PASSWORD
RUN echo $CONTAINER_IMAGE_VER

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get -qq update && apt-get -qq upgrade \
  && apt-get -qq install -y --no-install-recommends \
    bind9-host \
    build-essential \
    ca-certificates \
    exa \
    gnupg \
    curl \
    fasd \
    file \
    git-core \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libnss3-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    locales \
    lsof \
    make \
    netcat \
    nmap \
    net-tools \
    python3-pip \
    ruby \
    ruby-dev \
    scala \
    socat \
    software-properties-common \
    strace \
    sudo \
    sysstat \
    tcpdump \
    unzip \
    zip \
    zsh-syntax-highlighting \
    tmux \
    wget \
    zlib1g-dev \
    zsh \
  && locale-gen --purge fr_FR.UTF-8 \
  && echo -e 'LANG="fr_FR.UTF-8"\nLANGUAGE="fr"\n' > /etc/default/locale \
  && echo "Europe/Paris" > /etc/timezone \
  && adduser --quiet --disabled-password --shell $(which zsh) --home /home/$USER_NAME --gecos "User" $USER_NAME \
  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME \
  && mkdir -p $HOME/.config

#USER $USER_NAME

# Install Python from source
#RUN wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz \
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_VERSION_FILE \
  && tar xf $PYTHON_VERSION_FILE \
  && cd Python-3.9.6/ \
  && ./configure --enable-optimizations \
  && make -j 2 \
  && sudo make altinstall \
  && rm $PYTHON_VERSION_FILE \
  && rm -rf ${PYTHON_VERSION_FILE%%.tgz}

RUN apt-get -qq install -y --no-install-recommends \
    vim \
    neovim \
    python3-venv \
    python3-neovim \
  && apt-get -y -qq autoremove \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pyenv
RUN git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"

# Rbenv
RUN git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT"

# Nvm : https://github.com/creationix/nvm#install-script
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

RUN bash -c " \
  source $HOME/.profile && \
  nvm install $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default && \
  nvm install $NODE_LTS_VERSION && \
  nvm use $NODE_LTS_VERSION \
  "

# Oh-My-Zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Oh-My-Zsh plugins
RUN git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1 \
  && ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" \
  && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions \
  && git clone git://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting \
  && git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open

# Brew
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#RUN bash -c " \
#  brew tap buo/cask-upgrade && \
#  brew tap jakewmeyer/geo && \
#  brew tap neovim/neovim && \
#  brew tap universal-ctags/universal-ctags \
#  "
# Git credential
#RUN brew install git-credential-manager

ADD . /$DOTFILES_DIR

# Install dotfiles
RUN /$DOTFILES_DIR/build.sh

CMD ["zsh", "-l"]

# vim: set ft=Dockerfile:
