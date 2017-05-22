#!/bin/bash -i

#. includes/functions.sh
. includes/variable.sh



if [[ "$VERSION" =~ 7.* ]] || [[ "$VERSION" =~ 8.* ]]; then
		if [ "$(id -u)" -ne 0 ]; then
			echo "Ce script doit être exécuté en root"
			exit 1
		fi
	else
			echo "Ce script doit être exécuté sur Debian 7 ou 8 exclusivement"
			exit 1
	fi



if [[ ! -d "$CONFDIR" ]]; then
	clear
	echo -e "${BLUE}##########################################${NC}"
	echo -e "${BLUE}###    INSTALLING SEEDBOX-COMPOSE      ###${NC}"
	echo -e "${BLUE}##########################################${NC}"

	mkdir $CONFDIR
	echo ""
	echo -e "${BLUE}### INSTALL BASE PACKAGES ###${NC}"
	sed -ri 's/deb\ cdrom/#deb\ cdrom/g' /etc/apt/sources.list


	apt-get install -y \
	gawk \
	apache2-utils \
	htop \
	unzip \
	dialog \
	git \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	software-properties-common \
	locate \
	tree \
	openssl \
	members

	echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list
	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	apt-get update && apt-get upgrade -y

	echo -e "${BLUE}### DOCKER ###${NC}"
	dpkg-query -l docker > /dev/null 2>&1
  	if [ $? != 0 ]; then
		echo " * Installing Docker"
		apt-get install -y docker-engine
	fi

	systemctl start docker
	systemctl enable docker



	echo " * Installing Docker-compose"
	cat <<- EOF > /root/.profile
	alias docker-compose='docker run -v "$(pwd)":"$(pwd)" \
       	-v /var/run/docker.sock:/var/run/docker.sock \
       	-e UID=$(id -u) -e GID=$(id -g) \
       	-w "$(pwd)" \
       	-ti --rm xataz/compose:1.8'
	EOF



else
	clear
	echo -e " ${RED}--> Seedbox-Compose already installed !${NC}"
	script_option
fi