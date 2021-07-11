ARG version latest
FROM debian:${version:-latest}

MAINTAINER ca971

LABEL Description="ca971 Debian For Dev"

# Set shell command by SHELL [ “/bin/bash”, “-l”, “-c” ] and simply call RUN ....
SHELL [ "/bin/bash", "-l", "-c" ]

# Non privilegged User
#ARG USER_NAME="ca971"
#ARG USER_PASSWORD="p@$$w0d"

#ENV USER_NAME $USER_NAME
#ENV USER_PASSWORD $USER_PASSWORD

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

# Install minimum requirements and create new user
#RUN apt-get -qq update && apt-get -qq upgrade \
#  && apt-get -qq install -y --no-install-recommends \
#  wget \
#  sudo \
#  && adduser --quiet --disabled-password --shell $(which zsh) --home /home/$USER_NAME --gecos "User" $USER_NAME \
#  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME \
#  && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
#  && chmod 0440 /etc/sudoers.d/$USER_NAME \
#  && apt-get -y -qq autoremove \
#  && apt-get -qq clean \
#  && rm -rf /var/lib/apt/lists/* /dotfiles/* /var/dotfiles/*
#-a 'CASE_SENSITIVE="true"' \
#-a 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=transparent,bg=hsla(217,71%,44%,1),bold,underline"' \
#-a 'ZSH_AUTOSUGGEST_STRATEGY=(history completion)' \
#-a 'bindkey '^ ' autosuggest-accept' \
#-p git \
#-p sudo \
#-p vi-mode \

# Use non-privilegged user
USER $USER_NAME

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

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
