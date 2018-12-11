#!/bin/bash -i

. includes/functions.sh
. includes/variable.sh



if [[ "$VERSION" =~ 7.* ]] || [[ "$VERSION" =~ 8.* ]] || [[ "$VERSION" =~ 9.* ]] || [[ "$OS" = "Ubuntu" ]]; then
		if [ "$(id -u)" -ne 0 ]; then
			echo "Ce script doit être exécuté en root"
			exit 1
		fi
	else
			echo "Ce script doit être exécuté sur Debian 7/8/9 ou Ubuntu"
			exit 1
	fi



if [[ ! -d "$VOLUMES_TRAEFIK_PATH" ]]; then
	clear
	logo.sh
	echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
	echo -e "${CCYAN}					INSTALLATION DOCKER ET DOCKER-COMPOSE						   ${CEND}"
	echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
	echo ""
	echo ""
	if [ "$OS" = "Ubuntu" ]
		then
			apt update && apt upgrade -y
			apt install apache2-utils curl unzip -y
			curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
			curl -fsSL https://get.docker.com -o get-docker.sh
			sh get-docker.sh
			curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
			chmod +x /usr/local/bin/docker-compose
			mkdir -p /etc/apache2
			touch /etc/apache2/.htpasswd
			clear
			logo.sh
			echo -e "${CCYAN}Installation docker & docker compose terminée${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour continuer la configuration de traefik"
		else
			apt update && apt upgrade -y
			apt install apache2-utils curl unzip -y
			curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
			curl -fsSL https://get.docker.com -o get-docker.sh
			sh get-docker.sh
			curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
			chmod +x /usr/local/bin/docker-compose
			mkdir -p /etc/apache2
			touch /etc/apache2/.htpasswd
			clear
			logo.sh
			echo -e "${CCYAN}Installation docker & docker compose terminée${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour continuer la configuration de traefik"
		fi

	DOMAIN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\nles sous domaine seront gere plus tard :" 9 70 exemple.fr 3>&1 1>&2 2>&3)
	TRAEFIK_DASHBOARD_URL=$(whiptail --title "Panel Traefik" --inputbox "Adresse web traefik :" 9 80 traefik.${DOMAIN} 3>&1 1>&2 2>&3)
	USERNAME=$(whiptail --title "Authentification Traefik" --inputbox "Nom d'utilisateur pour l'authentification Traefik\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
	PASSWD=$(whiptail --title "Authentification Traefik" --passwordbox "Mot de passe pour l'authentification Traefik\ninterface web :" 9 80 3>&1 1>&2 2>&3)
	MAIL=$(whiptail --title "Adresse mail pour Traefik" --inputbox "Adresse mail :" 7 50 3>&1 1>&2 2>&3)

	htpasswd -bs /etc/apache2/.htpasswd "$USERNAME" "$PASSWD"
	htpasswd -cbs /etc/apache2/.htpasswd_"$USERNAME" "$USERNAME" "$PASSWD"
	VAR=$(sed -e 's/\$/\$$/g' /etc/apache2/.htpasswd_"$USERNAME" 2>/dev/null)
	export PROXY_NETWORK=traefik_proxy
	mkdir -p ${VOLUMES_TRAEFIK_PATH}
	mkdir -p /var/www
	cp -R ${BASEDIRDOCKER}/traefik/html /var/www/
	cp ${BASEDIRDOCKER}/traefik/traefik.toml  ${VOLUMES_TRAEFIK_PATH}/traefik.toml
	cp ${BASEDIRDOCKER}/traefik/docker-compose.yml ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml
	sed -i "s|@MAIL@|$MAIL|g;" ${VOLUMES_TRAEFIK_PATH}/traefik.toml
	sed -i "s|@DOMAIN@|$DOMAIN|g;" ${VOLUMES_TRAEFIK_PATH}/traefik.toml
	sed -i "s|@TRAEFIK_DASHBOARD_URL@|$TRAEFIK_DASHBOARD_URL|g;" ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml
	sed -i "s|@VOLUMES_TRAEFIK_PATH@|$VOLUMES_TRAEFIK_PATH|g;" ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml
	sed -i "s|@PROXY_NETWORK@|$PROXY_NETWORK|g;" ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml
	sed -i "s|@DOMAIN@|$DOMAIN|g;" ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml
	sed -i "s|@VAR@|$VAR|g;" ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml

	cat <<- EOF > "${VOLUMES_TRAEFIK_PATH}"/.env
	VAR=$VAR
	MAIL=$MAIL
	USERNAME=$USERNAME
	PASSWD=$PASSWD
	DOMAIN=$DOMAIN
	PROXY_NETWORK=$PROXY_NETWORK
	TRAEFIK_DASHBOARD_URL=$TRAEFIK_DASHBOARD_URL
	EOF

	docker network create traefik_proxy
	docker-compose -f ${VOLUMES_TRAEFIK_PATH}/docker-compose.yml up -d

else
	clear
	while :; do
	MANAGER=$(whiptail --title "Seedbox-Compose" --menu "Welcome to Seedbox-Compose Script. Please choose an action below :" 18 80 10 \
			"1" "Ajout et suppression d'utilisateurs" \
			"2" "Management application" \
			"3" "Ajout d'un domain" \
			"4" "SSL pour le domain" \
			"5" "suppression de Seedbox-Compose" \
			"6" "Sortir"  3>&1 1>&2 2>&3)
		echo ""

		case $MANAGER in
			1)
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


				;;
			2)
				echo -e " ${BWHITE}* Sickrage${NC}"
				cp -Rf "$BASEDIRDOCKER"/sickrage /home/"$SEEDUSER"/dockers
				sed_docker /home/"$SEEDUSER"/dockers/sickrage/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/sickrage/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				add_vhost sickrage 8081
				;;
			3)
				echo -e " ${BWHITE}* Couchpotato${NC}"
				cp -Rf "$BASEDIRDOCKER"/couchpotato /home/"$SEEDUSER"/dockers
				sed_docker /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				add_vhost couchpotato 5050
				;;
			6)
				echo -e " ${BWHITE}* Sortir${NC}"
				break
				;;

		esac
	done

fi