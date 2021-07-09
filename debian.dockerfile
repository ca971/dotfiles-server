FROM debian:${version:-latest}

MAINTAINER ca971

LABEL Description="ca971 Debian For Dev"

# Set shell command by SHELL [ “/bin/bash”, “-l”, “-c” ] and simply call RUN ....
SHELL [ "/bin/bash", "-l", "-c" ]

# tmp as working directory
WORKDIR /tmp

#ENV XDG_CONFIG_HOME="$HOME/.config"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# "vscode" user for "Vscode Remote Docker Container"
ARG USER_NAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Package bundle
RUN groupadd --gid $USER_GID $USER_NAME \
  && useradd -s $(which zsh) --uid $USER_UID --gid $USER_GID -m $USER_NAME \
  && apt-get -qq update && apt-get -qq upgrade \
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
  vim \
  neovim \
  python3-venv \
  && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
  && chmod 0440 /etc/sudoers.d/$USER_NAME \
  && apt-get -y -qq autoremove \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure locales
RUN locale-gen --purge fr_FR.UTF-8 \
  && echo -e 'LANG="fr_FR.UTF-8"\nLANGUAGE="fr_FR:fr"\n' > /etc/default/locale \
  && echo "Europe/Paris" > /etc/timezone

# Add a non-privileged user
#RUN adduser --quiet --disabled-password --shell $(which zsh) --home /home/$USER_NAME --gecos "User" $USER_NAME && \
#  echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME

USER $USER_NAME

#RUN mkdir -p $XDG_CONFIG_HOME

# Install pyenv, pyenv-virtualenv and default python version
ENV PYENV_ROOT $HOME/.pyenv
ENV PYTHONDONTWRITEBYTECODE true
ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV true
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

COPY .python-version /tmp/.python-version
COPY requirements.txt /tmp/requirements.txt

RUN curl https://pyenv.run | bash \
  && cd $PYENV_ROOT \
  && git checkout `git describe --abbrev=0 --tags` \
  && echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
RUN git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv \
  && echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc
RUN pyenv install $(cat .python-version) \
  && pyenv global $(cat .python-version) \
  && pip install --upgrade pip \
  && pip install -r requirements.txt \
  && python -V && pip -V

# Install nvm and default Node version
ENV NVM_DIR $HOME/.nvm
#COPY .nvmrc /tmp/.node-version
#ENV NODE_VERSION=$(cat .node-version)
#ENV NODE_PATH=$NVM_DIR/$NODE_VERSION/lib/node_modules
#ENV PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
  && echo 'source $NVM_DIR/nvm.sh' >> $HOME/.bashrc \
  && nvm install && nvm use \
  && node -v && npm -v

ENV PATH=/usr/local/rvm/bin:$PATH

## Install default Ruby version
COPY .ruby-version /tmp/.ruby-version

RUN curl -L https://get.rvm.io | bash -s stable \
  && rvm requirements \
  && rvm install $(cat .ruby-version) \
  && vm use --default $(cat .ruby-version) \
  && gem install bundler \
  && rvm cleanup all

# Install Homebrew for linux
ENV PATH=$HOME/.linuxbrew/bin:$PATH

RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
  && mkdir ~/.linuxbrew/bin \
  && ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin \
  && eval $(~/.linuxbrew/bin/brew shellenv) \
  && brew --version \
  && brew tap homebrew/core \
  && brew tap buo/cask-upgrade \
  && brew tap jakewmeyer/geo \
  && brew tap neovim/neovim \
  && brew tap universal-ctags/universal-ctags


# Install Oh-my-zsh with zsh-in-docker
# https://github.com/deluan/zsh-in-docker/blob/master/Dockerfile
RUN wget -O- "https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh" -- \
  -t https://github.com/denysdovhan/spaceship-prompt \
  -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
  -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
  -p git \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-completions \
  -p https://github.com/zsh-users/zsh-history-substring-search \
  -p https://github.com/zsh-users/zsh-syntax-highlighting \
  -p 'history-substring-search' \
  -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
  -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

ENTRYPOINT [ "/bin/zsh" ]

CMD ["-l"]
