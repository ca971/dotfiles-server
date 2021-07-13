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
    -a 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#005073,bold,underline"' \
    -p https://github.com/paulirish/git-open \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

WORKDIR /tmp

# Install Python from source
#RUN wget -P /tmp https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
#  && tar xf Python-$PYTHON_VERSION.tgz \
#  && cd Python-$PYTHON_VERSION/ \
#  && ./configure --enable-optimizations \
#  && make -j 2 \
#k  && sudo make altinstall

# Install pyenv, pyenv-virtualenv and default python version
ENV PYTHON_VERSION 3.9.6
ENV PYTHONDONTWRITEBYTECODE true
ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV true

COPY requirements.txt /tmp

# Set PATH
ENV PATH=~/.pyenv/shims:~/.pyenv/bin:~/.rbenv/shims:~/.rbenv/bin:~/.nvm/bin:/usr/local/rvm/bin:~/.linuxbrew/bin:$PATH:/usr/games

RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
  && mkdir \
    ~/.linuxbrew/bin \
    ~/.nvm \
    ~/.pyenv \
    ~/.rbenv \
    ~/.ssh \
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
  pyenv \
  pyenv-virtualenv \
  pipenv \
  rbenv \
  bat \
  fzf \
  grc \
  git-credential-manager \
  nvm

# Set python3 and pip3 as default python
RUN update-alternatives --install /usr/bin/python python $HOME/.pyenv/versions/bin/python 3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1

#RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python${PYTHON_VERSION%.*} 2
#RUN update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip${PYTHON_VERSION%.*} 2
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
#RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 1

RUN \
  nvm install node \
  && nvm alias default node \
  && nvm use default \
  && nvm install --lts \
  && nvm use --lts \
  && npm install -g yarn

RUN \
    pyenv install $PYTHON_VERSION \
    && pyenv virtualenv $PYTHON_VERSION python_3 \
    && pyenv global python_3

RUN \
    pip install --upgrade pip \
    pip install -r /tmp/requirements.txt


COPY id_rsa /tmp

# SSH
RUN \
    eval $(ssh-agent -s) \
    && mkdir ~/.ssh \
    && mv id_rsa ~/.ssh \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && cat /etc/ssh_config \
    && chmod go-w /root \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/id_rsa \
    && ssh-add ~/.ssh/id_rsa
#&& git clone <your-git-repo-ssh-url>

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
