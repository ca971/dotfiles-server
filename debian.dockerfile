ARG version latest
FROM debian:${version:-latest}

MAINTAINER ca971

LABEL Description="ca971 Debian For Dev"

# Set shell command by SHELL [ “/bin/bash”, “-l”, “-c” ] and simply call RUN ....
SHELL [ "/bin/bash", "-l", "-c" ]


# Non privileged user
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
#USER $USER_NAME

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

COPY requirements.txt /tmp
WORKDIR /tmp

# Install Pyenv
RUN curl https://pyenv.run | bash
RUN eval "$(pyenv init --path)"
RUN eval "$(pyenv init -)"
RUN eval "$(pyenv virtualenv-init -)"
RUN pyenv install $PYTHON_VERSION \
  && pyenv global $PYTHON_VERSION \
  && pip install --upgrade pip \
  && pip install -r requirements.txt \
  && python -V && pip -V

# Install Rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

# Install nvm and default Node version
ENV NODE_VERSION 16.4.2
ENV NODE_LTS_VERSION 14.17.3

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && nvm install $NODE_LTS_VERSION \
  && nvm use $NODE_LTS_VERSION

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

CMD ["/usr/bin/zsh","-l"]
