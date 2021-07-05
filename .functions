# Header, Success, Info, User and Error stuffs
# =============================================================================
function e_header() {
  echo -e "\n\033[1m$@\033[0m";
}

function e_success() {
  echo -e " [ \033[1;32m✔\033[0m ] $@";
}

function e_info() {
  echo -e "\n [ \033[1;34m..\033[0m" ] $@;
}

function e_user() {
  echo -e "\n [ \033[1;33m??\033[0m" ] $@;
}

function e_error() {
  echo -e " [ \033[1;31m✖\033[0m ] $@";
}

# Detect OS
# =============================================================================
function is_osx() {
  [[ "$OSTYPE" == "darwin"* ]] || return 1
}

function is_linux() {
  [[ "$OSTYPE" == "linux-gnu" ]] || return 1
}

function is_debian() {
  [[ $(cat /etc/issue >/dev/null 2>&1) =~ "Debian" ]] || return 1
}

function is_ubuntu() {
  [[ $(cat /etc/issue >/dev/null 2>&1) =~ "Ubuntu" ]] || return 1
}

function is_centos() {
  [[ -e /etc/centos-release || -e /etc/redhat-release ]] || return 1
}

function is_freebsd() {
  [[ "$OSTYPE" == "freebsd" ]] || return 1
}

function is_openbsd() {
  [[ "$OSTYPE" == "openbsd"* ]] || return 1
}

function is_netbsd() {
  [[ "$OSTYPE" == "netbsd" ]] || return 1
}

function is_solaris() {
  [[ "$OSTYPE" == "(solaris|sunos|indiana|illumos|smartos)"* ]] || return 1
}

function is_cygwin() {
  [[ "$OSTYPE" == "cygwin" ]] || return 1
}

function is_msys() {
  [[ "$OSTYPE" == "msys" ]] || return 1
}

function is_windows() {
  [[ "$OSTYPE" == "win32" ]] || return 1
}

function get_os() {
  local sys=(
  osx
  linux
  debian
  ubuntu
  centos
  freebsd
  openbsd
  netbsd
  solaris
  msys
  cygwin
  windows
)

for os in "${sys[@]}"; do
  is_$os; [[ $? == ${1:-0} ]] && echo $os
done
unset os sys
}

# Detect SHELL
# =============================================================================

function is_zsh() {
  [ -n "$ZSH_VERSION" ] || return 1
}

function is_bash() {
  [ -n "$BASH_VERSION" ] || return 1
}

function is_fish() {
  [ -n "$FISH_VERSION" ] || return 1
}

# Mode success or error
# =============================================================================
function assign() {
  local modes=(
  "e_success"
  "e_error"
)

if [ $1 == 0 ]; then
  return $modes[1]
else
  return $modes[2]
fi
}

# Reload via $SHELL or zshrc/bashrc
# =============================================================================
function reload() {
  if [ -n "$1" -a is_zsh ]; then
    . "$HOME/.zshrc"
  elif [ -n "$1" -a is_bash ]; then
    . "$HOME/.bashrc"
  else
    exec "$SHELL"
  fi
}

# Directory
# =============================================================================
function mkd() {
  mkdir -pv "$@" && cd "$_";
}

# Grep
# =============================================================================
# Find specific alias
function alg() {
  alias | grep "${1:="ls"}"
}

# https://news.ycombinator.com/item?id=18898523
function grepall() {
  grep -rnI "$@" **/*
  #grep -rnw ~/.dotfiles -e "alias"
}

function r() {
  grep "$1" ${@:2} -R .
}

# Git
# =============================================================================
#Git add, commit, push
function acp() {
  git add .
  git commit -m "$1"
  git push
}

# Tmux
# =============================================================================
# Only exit if we're not on the last pane
function exit() {
  if [[ -z $TMUX ]]; then
    builtin exit
    return
  fi

  panes=$(tmux list-panes | wc -l)
  wins=$(tmux list-windows | wc -l)
  count=$(($panes + $wins - 1))
  if [ $count -eq 1 ]; then
    tmux detach
  else
    builtin exit
  fi
}

# Open tmux session in ssh terminal
# ssh_tmux user@servername
# If you lost this connexion, you can relaunch it
function ssh_tmux() {
  ssh -t "$1" tmux a || ssh -t "$1" tmux;
}

# https://vimeo.com/108223630
function tm() {
  if [ -z "$TMUX" ]; then
    tmux attach-session -t $1
  else
    tmux switch-client -t $1
  fi
}

function _tmux_complete_session() {
  local IFS=$'\n'
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$(tmux -q list-sessions -F '#{session_name}')" -- "${cur}") )
}

# Network
# =============================================================================
function ip_addr() {
  echo "Renseigne-moi sur mon adresse IP ..."
  while :
  do
    read IP_ADDR
    case $IP_ADDR in
      ip)
        curl ipinfo.io/ip
        ;;
      eth0)
        curl eth0.me
        ;;
      checkip)
        curl checkip.amazonaws.com
        ;;
      ican)
        curl icanhazip.com
        ;;
      json)
        curl httpbin.org/ip
        ;;
      geo)
        curl ipinfo.io/8.8.8.8
        ;;
      loc)
        curl ipinfo.io/8.8.8.8/loc
        ;;
      country)
        curl ifconfig.co/country
        ;;
      city)
        ifconfig.co/city
        ;;
      bye)
        echo "See you next time !!!"
        break
        ;;
      *)
        echo "Vous devez choisir entre 'ip', 'eth0', 'checkip', 'ican', 'json', 'geo', 'loc', 'country' et 'city'"
        ;;
    esac
  done
}

# Miscelleanous
# =============================================================================
# Exists function
function _exists() {
  command -v $1 > /dev/null 2>&1; echo "$(( !$? ))";
}

# File search functions
function f() {
  find . -iname "*$1*" ${@:2}
}

# Gets ownership
function gown() {
  sudo chown -R "${USER}" "${1:-.}"
}

# Displays user owned process status
function pmine() {
  ps "$@" -u "$USER" -o pid,%cpu,%mem,command
}

function cheat() {
  curl cheat.sh/${1};
}

if is_bash; then
  # Remove an entry from $PATH
  # http://stackoverflow.com/a/2108540/142339
  function path_remove() {
    local arg path
    path=":$PATH:"
    for arg in "$@"; do path="${path//:$arg:/:}"; done
    path="${path%:}"
    path="${path#:}"
    echo "$path"
  }
fi

# Set the terminal's title bar.
function titlebar() {
  echo -n $'\e]0;'"$*"$'\a'
}

function wttr() {
  curl fr.wttr.in/${1:="Dammarie-les-lys"};
}

# https://pnguyen.io/posts/improve-productivity-with-fzf/
function zf() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf -1 -0 --reverse --height 30% --no-sort +m)" && cd "${dir}" || return 1
}

# https://edmondscommerce.github.io/programming/linux/ubuntu/building-bash-function-libraries.html
function parse_f() { # auto complete helper, second argument is a grep against the function list
  if [[ '' == "$@" ]]
  then
    echo "Parse Namespaced Functions List"
    cat $(is_zsh && ${(%):-%N} || $BASH_SOURCE) | grep "^function [^(]" | echo "List Namespaced functions"
    #cat $(is_zsh && ${(%):-%N} || $BASH_SOURCE) | grep "^function[^(]" | awk '{j=" USAGE:"; for (i=5; i<=NF; i++) j=j" "$i; print $2" "j}'
  else
    echo "Parse Functions Matching: $@"
    cat $(is_zsh && ${(%):-%N} || $BASH_SOURCE) | grep "^function [^(]" | echo "Matching parsed functions"
    #cat $(is_zsh && ${(%):-%N} || $BASH_SOURCE) | grep "^function[^(]" | awk '{j=" USAGE:"; for (i=5; i<=NF; i++) j=j" "$i; print $2" "j}' | grep $@
  fi
}

# Docker
# =============================================================================
# Docker clean
function docker_clean() {
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
  docker volume prune
}

# Docker machine
# =============================================================================
function docker-machine-size() {
  (cd  ~/.docker/machine/machines; du -d1 -h .)
}

function docker-machine-active() {
  if [ -z "$DOCKER_HOST" ]; then
    echo "Docker Toolbox environment not initialized, trying to infer running machines"
    echo ""
    docker-machine ls 2>/dev/null | grep "Running"
    echo ""
    echo "Please run "
    echo "  docker-machine-create   : creates a new docker machine hosted in Virtualbox"
    echo "  docker-machine-init      : initializes the Docker Toolbox"
    return
  fi

  docker-machine active 2>/dev/null
}

function docker-machine-create() {
  machine=${1:-default}

  if [ -z $machine ]; then
    echo "No machine name specified, exiting..."
    return
  fi

  echo "Creating new machine $machine"
  docker-machine create -d virtualbox $machine
}

function docker-machine-rm() {
  machine=${1:-default}

  if [ -z "$machine" ]; then
    echo "No docker machine specified"
    machine=$DOCKER_MACHINE_NAME
    if [ -z "$machine" ]; then
      echo "Did not find any default machine, exiting..."
      return
    fi
    echo "Will stop default machine"
  fi

  read -p "Remove machine $machine [y|(n)]: " answer
  if [ -z "$answer" ] || [ "$answer" != "y" ]
  then
    echo "No, all right, exiting with removing..."
    return
  fi

  echo "Removing machine $machine"
  docker-machine rm $machine
}

function docker-machine-stop() {
  machine=${1:-default}

  if [ -z "$machine" ]; then
    echo "No docker machine specified"
    machine=$DOCKER_MACHINE_NAME
    if [ -z "$machine" ]; then
      echo "Did not find any default machine, exiting..."
      return
    fi
    echo "Will stop default machine"
  fi

  echo "Stopping machine $machine"
  docker-machine stop $machine
}

function docker-machine-start() {
  machine=${1:-default}

  if [ -z "$machine" ]; then
    echo "No docker machine specified, please try again..."
    docker-machine-ls
    return
  fi

  echo "Starting machine $machine ..."
  docker-machine start $machine
}

# Initialize the Windows Docker Toolbox environment
#   - autmatically detects the running docker machine
function docker-machine-init() {
  machine=${1:-default}
  if [ -z "$machine" ]; then
    echo "No docker machine specified, looking for a machine currently running..."
    eval machine="$(docker-machine ls --filter state=Running | grep Running |  cut -f 1 -d ' ')"
    if [ -z "$machine" ]; then
      echo "No docker machine is currently running"
      echo "You may "
      echo "   docker-machine-ls          : list existing machines"
      echo "   docker-machine-create      : create a new docker machine"
      echo "   docker-machine-start       : start an existing docker maxchine"
      return
    fi
    echo "Found machine $machine"
  fi

  echo "Initializing env for machine $machine ... "
  eval "$(docker-machine env $machine)"

  if [ $machine != $DOCKER_MACHINE_NAME ]; then
    echo "Machine $machine does not exists"
    echo "Please run docker-machine-ls to list existing machines, exiting ..."
    return
  fi

  eval DOCKER_HOST_IP="$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')"
  export DOCKER_HOST_IP
  echo "Docker environnement initialized with machine: $machine"
}

function docker-machine-reset() {
  machine=${1:-default}

  if [ -z "$machine" ]; then
    echo "No docker machine specified, looking for a machine currently running..."
    eval machine="$(docker-machine ls --filter state=Running | grep Running |  cut -f 1 -d ' ')"
    if [ -z "$machine" ]; then
      echo "No docker machine is currently running"
      echo "You may "
      echo "   docker-machine-create      : create a new docker machine"
      echo "   docker-machine-start       : start an existing docker maxchine"
      return
    fi
    echo "Found machine $machine"
  fi

  echo "Regenerating certs for machine $machine ... "
  docker-machine regenerate-certs -f $machine

  echo "Initializing docker env..."
  docker-machine-init $machine
}

function docker-machine-env() {
  echo "DOCKER_MACHINE_NAME : $DOCKER_MACHINE_NAME"
  echo "DOCKER_HOST_IP      : $DOCKER_HOST_IP"
  echo "DOCKER_HOST         : $DOCKER_HOST"
}

function docker-machine-ip() {
  machine=${1:-default}
  if [ -z "$machine" ]; then
    eval machine="$(docker-machine active 2>/dev/null)"
  fi
  docker-machine ip $machine
}


# vim: set ft=bash:
