#!/bin/bash -i


#couleus
RED='\e[0;31m'
GREEN='\033[0;32m'
BLUEDARK='\033[0;34m'
BLUE='\e[0;36m'
YELLOW='\e[0;33m'
BWHITE='\e[1;37m'
NC='\033[0m'

#variables
BASEDIR="/opt/seedbox-compose"
CONFDIR="/etc/seedboxcompose"
VERSION=$(cat /etc/debian_version)
USERSFILE="/etc/seedboxcompose/users.txt"
USERID=$(id -u $SEEDUSER)
GRPID=$(id -g $SEEDUSER)