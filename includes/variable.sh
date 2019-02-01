#!/bin/bash -i


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CPURPLE="${CSI}1;35m"
CCYAN="${CSI}1;36m"

#variables
BASEDIR="/opt/seedbox"
CONFDIR="${BASEDIR}/conf"
BASEDIRDOCKER="${BASEDIR}/dockers"
VOLUMES_TRAEFIK_PATH="/etc/traefik"


VERSION=$(cat /etc/debian_version)
OS=$(cat /etc/*release | grep ^NAME | tr -d 'NAME="')