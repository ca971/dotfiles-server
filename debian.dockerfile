ARG version latest
FROM debian:${version:-latest}

MAINTAINER ca971

LABEL Description="ca971 Debian For Dev"

# Set shell command by SHELL [ “/bin/bash”, “-l”, “-c” ] and simply call RUN ....
SHELL [ "/bin/bash", "-l", "-c" ]


ARG USER_NAME=ca971
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME \
    && apt-get update \
    && apt-get install -y sudo wget \
    && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Add a non-privileged user
#RUN adduser --quiet --disabled-password --shell $(which zsh) --home /home/$USER_NAME --gecos "User" $USER_NAME && \
#  echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME

USER $USER_NAME

# Install Oh-my-zsh with zsh-in-docker
# https://github.com/deluan/zsh-in-docker/blob/master/Dockerfile
# RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
COPY zsh-docker.sh /tmp
RUN /tmp/zsh-docker.sh \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p sudo \
    -p vi-mode \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'
#RUN mkdir -p $XDG_CONFIG_HOME

# Install pyenv, pyenv-virtualenv and default python version
#ENV PYENV_ROOT /root/.pyenv
#ENV PYTHONDONTWRITEBYTECODE true
#ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV true
#ENV PYTHON_VERSION 3.9.6

#COPY .python-version /dotfiles/.python-version
#COPY requirements.txt /dotfiles/requirements.txt


#&& git checkout `git describe --abbrev=0 --tags` \
#ENV PYTHON_VERSION=$(cat .python-version)

RUN curl https://pyenv.run | bash

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

#  && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.profile \
#  && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile \
#  && echo 'eval "$(pyenv init --path)"' >> ~/profile \
#  && echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc \
#  && echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc \
#  && pyenv install $PYTHON_VERSION \
#  && pyenv global $PYTHON_VERSION \
#  && pip install --upgrade pip \
#  && pip install -r requirements.txt \
#  && python -V && pip -V

#ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install nvm and default Node version
#ENV NVM_DIR $HOME/.nvm
#COPY .nvmrc /dotfiles/.nvmrc
#ENV NODE_VERSION=$(cat .node-version)
#ENV NODE_PATH=$NVM_DIR/$NODE_VERSION/lib/node_modules
#ENV PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

#RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
#  && echo 'source $NVM_DIR/nvm.sh' >> $HOME/.bashrc \
#  && nvm install && nvm use \
#  && node -v && npm -v

#ENV NODE_VERSION 16.4.2
ENV NODE_VERSION node
ENV NODE_LTS_VERSION 14.17.3

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && nvm install $NODE_LTS_VERSION \
  && nvm use $NODE_LTS_VERSION

# this now works
#RUN nvm install && nvm use
#ENV PATH=/usr/local/rvm/bin:$PATH
#source $NVM_DIR/nvm.sh && \
#  nvm install $NODE_VERSION && \
#  nvm alias default $NODE_VERSION && \
#  nvm use default && \
#  nvm install $NODE_LTS_VERSION && \
#  nvm use $NODE_LTS_VERSION \

## Install default Ruby version
#COPY .ruby-version /dotfiles/.ruby-version
#ENV RUBY_VERSION 3.0.8

#RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 \
#  && curl -L https://get.rvm.io | bash -s stable \
#  && rvm requirements \
#  && rvm install $RUBY_VERSION \
#  && vm use --default $RUBY_VERSION \
#  && gem install bundler --no-ri --no-rdoc \
#  && rvm cleanup all


# Install RVM
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys \
#      409B6B1796C275462A1703113804BB82D39DC0E3 \
#      7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
# && curl -sSL https://get.rvm.io | bash -s -- --autolibs=read-fail stable \
# && echo 'bundler' >> /root/.rvm/gemsets/global.gems \
# && echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc
#
## Install Rubies
#RUN rvm install 3.0.8 \
# && rvm alias create 3.0 ruby-3.0.8 \
# && rvm use --default 3.0.8

# Install Homebrew for linux
#ENV PATH=$HOME/.linuxbrew/bin:$PATH

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



ENTRYPOINT [ "/bin/zsh" ]

CMD ["-l"]
