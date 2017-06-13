#!/bin/bash -i

. includes/functions.sh
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
	checking_errors $? installation

	echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list
	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	apt-get update && apt-get upgrade -y

	echo -e "${BLUE}### DOCKER ###${NC}"
	dpkg-query -l docker > /dev/null 2>&1
  	if [ $? != 0 ]; then
		echo " * Installing Docker"
		apt-get install -y docker-engine
		checking_errors $? docker
		systemctl start docker
		checking_errors $? start-docker
		systemctl enable docker
		checking_errors $? activation-docker
	fi





	echo " * Installing Docker-compose"
	curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	checking_errors $? docker-compose
	docker-compose



	SEEDUSER=$(whiptail --title "Username" --inputbox \
		"Please enter a username :" 7 50 3>&1 1>&2 2>&3)
	PASSWORD=$(whiptail --title "Password" --passwordbox \
		"Please enter a password :" 7 50 3>&1 1>&2 2>&3)

	echo -e " ${BWHITE}* Adding $SEEDUSER to the system"
	useradd -M -s /bin/bash "$SEEDUSER"
	checking_errors $? ajout-user
	echo "${SEEDUSER}:${PASSWORD}" | chpasswd
	mkdir -p /home/"$SEEDUSER"/{watch,torrents,dockers}
	chown -R "$SEEDUSER":"$SEEDUSER" /home/"$SEEDUSER"
	chown root:"$SEEDUSER" /home/"$SEEDUSER"
	chmod 755 /home/"$SEEDUSER"
	USERID=$(id -u $SEEDUSER)
	GRPID=$(id -g $SEEDUSER)

	sed -i "s/Subsystem[[:blank:]]sftp[[:blank:]]\/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g;" /etc/ssh/sshd_config
	sed -i "s/UsePAM/#UsePAM/g;" /etc/ssh/sshd_config

	cat <<- EOF >> /etc/ssh/sshd_config
	Match User $SEEDUSER
	ChrootDirectory /home/$SEEDUSER
	EOF

	service ssh restart
	checking_errors $? restart-ssh


	if [[ ! -f "$CONFDIR"/users.txt ]]; then
		echo "$SEEDUSER" >> "$CONFDIR"/users.txt
	fi
	if [[ ! -f "$CONFDIR"/ports.txt ]]; then
		echo "5050" >> "$CONFDIR"/ports.txt
		PORT="5050"
	fi


	ACTION=$(whiptail --title "Services manager" --checklist \
	"Please select services you want to add for $SEEDUSER (Use space to select)" 28 60 17 \
			"1" "RuTorrent" OFF \
			"2" "Sickrage" OFF \
			"3" "Couchpotato" OFF \
			"4" "Portainer" OFF 3>&1 1>&2 2>&3)
		echo ""

		ACTION="$(echo $ACTION | tr -d '"')"


		cp "$BASEDIRDOCKER"/boring-nginx/docker-compose.yml "$CONFDIR"
		mkdir "$CONFDIR"/nginx/{sites-enabled,conf,log,certs,passwds,www}
		cp "$BASEDIRDOCKER"/boring-nginx/seedbox.conf "$CONFDIR"/nginx/sites-enabled/seedbox.conf

		htpasswd -bs "$CONFDIR"/nginx/passwds/seed.htpasswd "$SEEDUSER" "${PASSWORD}"
		chmod 640 "$CONFDIR"/nginx/passwds/*



	for APP in $(echo $ACTION)
	do
		case $APP in
			1)
				echo -e " ${BWHITE}* RuTorrent${NC}"
				cp -Rf "$BASEDIRDOCKER"/rutorrent /home/"$SEEDUSER"/dockers
				calcul_port 5050 45000
				echo "$PORT" >> "$CONFDIR"/ports.txt
				sed_docker /home/"$SEEDUSER"/dockers/rutorrent/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/rutorrent/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				;;
			2)
				echo -e " ${BWHITE}* Sickrage${NC}"
				cp -Rf "$BASEDIRDOCKER"/sickrage /home/"$SEEDUSER"/dockers
				calcul_port 5050
				echo "$PORT" >> "$CONFDIR"/ports.txt
				sed_docker /home/"$SEEDUSER"/dockers/sickrage/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/sickrage/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				;;
			3)
				echo -e " ${BWHITE}* Couchpotato${NC}"
				cp -Rf "$BASEDIRDOCKER"/couchpotato /home/"$SEEDUSER"/dockers
				calcul_port 5050
				echo "$PORT" >> "$CONFDIR"/ports.txt
				sed_docker /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				;;
			4)
				echo -e " ${BWHITE}* Portainer${NC}"
				cp -Rf "$BASEDIRDOCKER"/portainer /home/"$SEEDUSER"/dockers
				calcul_port 5050
				echo "$PORT" >> "$CONFDIR"/ports.txt
				sed_docker /home/"$SEEDUSER"/dockers/portainer/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/portainer/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				;;

		esac
	done

else
	clear
	echo -e " ${RED}--> Seedbox-Compose already installed !${NC}"
	script_option
fi