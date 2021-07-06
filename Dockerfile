FROM debian:latest
LABEL Description="Debian for Dev"

ENV DEBIAN_FRONTEND noninteractive

RUN bash -c ' \
        apt-get update && \
        apt-get upgrade -y && \
        apt-get install -y \
            bind9-host \
            build-essential \
            curl \
            git \
            lsof \
            make \
            netcat \
            nmap \
            net-tools \
            python-dev \
            python-pip \
            python-setuptools \
            ruby \
            ruby-dev \
            scala \
            socat \
            strace \
            sysstat \
            tcpdump \
            unzip \
            vim \
            wget \
            zip \
            zsh \
            zsh-syntax-highlighting && \
        apt-get autoremove -y && \
        apt-get clean \
        '

ADD ./ /dotfiles

RUN zsh </dotfiles/install.zsh

CMD zsh -l
