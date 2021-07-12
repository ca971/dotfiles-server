ARG version bullseye
FROM debian:${version:-latest}

LABEL maintainer="ca971 <contact@ca971.dev>"
LABEL name="PaaS-docker"
LABEL version="latest"

# Non Interactive MODE
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Set shell command by SHELL [ “/bin/bash”, “-l”, “-c” ] and simply call RUN ....
SHELL [ "/bin/bash", "-l", "-c" ]

# Set the SHELL to bash with pipefail option
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Non privileged user
ARG USER_NAME=ca971
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Add sources.list
COPY bullseye-sources.list /etc/apt/sources.list

RUN \
    export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="1" \
    && apt-get update \
    && apt-get install -y sudo wget

# Add a group for $USER_NAME
RUN groupadd --gid $USER_GID $USER_NAME

# Add a non-root User
RUN useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME

# Set Sudoers for $USER_NAME
RUN echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME

# Protect $USER_NAME sudo file
RUN chmod 0440 /etc/sudoers.d/$USER_NAME

# Set permissions for $USER_NAME directory
RUN chown $USER_NAME:$USER_NAME -R "/home/$USER_NAME"

# User "$USER_NAME" as non-root user
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
    -p fzf \
    -p vi-mode \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

WORKDIR /tmp

ENV PYTHON_VERSION 3.9.6

# Install Python from source
RUN wget -P /tmp https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
  && tar xf Python-$PYTHON_VERSION.tgz \
  && cd Python-$PYTHON_VERSION/ \
  && ./configure --enable-optimizations \
  && make -j 2 \
  && sudo make altinstall

# Install pyenv, pyenv-virtualenv and default python version
ENV PYTHONDONTWRITEBYTECODE true
ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV true

COPY requirements.txt /tmp

# Install Pyenv
RUN curl https://pyenv.run | bash
RUN eval "$(pyenv init --path)"
RUN eval "$(pyenv init -)"
RUN eval "$(pyenv virtualenv-init -)"
#RUN eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

# Install Rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

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
  && brew tap universal-ctags/universal-ctags \
  && brew tap homebrew/aliases \
  && brew update && brew install \
  nvm \
  bat \
  fzf

# Set PATH
ENV PATH=~/.pyenv/shims:~/.pyenv/bin:~/.rbenv/shims:~/.rbenv/bin:~/.nvm/bin:/usr/local/rvm/bin:~/.linuxbrew/bin:$PATH:/usr/games

# Clean and erase apt cache
RUN apt-get clean -y \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/*

# Tells systemd that it's running inside a Docker container environment
ENV container docker

ADD . $HOME/code

WORKDIR $HOME/code

CMD ["/bin/zsh","-l"]

# vim: set ft=dockerfile:
