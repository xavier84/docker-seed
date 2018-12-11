#!/bin/bash -i


#couleus
RED='\e[0;31m'
GREEN='\033[0;32m'
BLUEDARK='\033[0;34m'
BLUE='\e[0;36m'
YELLOW='\e[0;33m'
BWHITE='\e[1;37m'
NC='\033[0m'

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CPURPLE="${CSI}1;35m"
CCYAN="${CSI}1;36m"

#liste des appliquetions
LISTAPP="plex pyload medusa rtorrent radarr syncthing jackett lidarr portainer tautulli nextcloud heimdall"
#variables
BASEDIR="/opt/seedbox"
CONFDIR="${BASEDIR}/conf"
BASEDIRDOCKER="${BASEDIR}/dockers"
VOLUMES_TRAEFIK_PATH="/etc/traefik"


VERSION=$(cat /etc/debian_version)
OS=$(cat /etc/*release | grep ^NAME | tr -d 'NAME="')