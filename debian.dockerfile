FROM debian:latest
MAINTAINER ca971

LABEL Description="Debian For Dev"

ARG DEBIAN_FRONTEND=noninteractive

ARG USER_NAME="ca971"
ARG USER_PASSWORD="p@$$w0d"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD
ENV CONTAINER_IMAGE_VER=v1.0.0

RUN echo $USER_NAME
RUN echo $USER_PASSWORD
RUN echo $CONTAINER_IMAGE_VER

RUN apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    bind9-host \
    build-essential \
    curl \
    git-core \
    ca-certificates \
    lsof \
    make \
    netcat \
    nmap \
    net-tools \
    ruby \
    ruby-dev \
    scala \
    socat \
    strace \
    sysstat \
    tcpdump \
    unzip \
    zip \
    zsh-syntax-highlighting \
    locales \
    gnupg \
    wget \
    exa \
    tmux \
    zsh \
    vim \
    neovim \
    python3-neovim \
  && locale-gen fr_FR.UTF-8 \
  && adduser --quiet --disabled-password --shell /bin/zsh --home /home/$USER_NAME --gecos "User" $USER_NAME \
  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME \
  && apt-get -y -qq autoremove \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER $USER_NAME
ENV TERM xterm
ENV ZSH_THEME spaceship

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

ENV ZSH_CUSTOM=/home/$USER_NAME/.oh-my-zsh/custom

RUN git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
RUN ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

ADD . /dotfiles

RUN /dotfiles/build.sh

CMD zsh -l
