#!/bin/bash -i

checking_errors() {
	if [[ "$1" == "0" ]]; then
		echo -e "	${GREEN}--> Operation "$2" success !${NC}"
	else
		echo -e "	${RED}--> Operation "$2" failed !${NC}"
	fi
}

sed_docker() {
sed -i \
	-e "s|@FILMS@|$FILMS|g" \
	-e "s|@SERIES@|$SERIES|g" \
	-e "s|@ANIMES@|$ANIMES|g" \
	-e "s|@MUSIC@|$MUSIC|g" \
	-e "s|@VOLUMES_ROOT_PATH@|$VOLUMES_ROOT_PATH|g" \
	-e "s|@VAR@|$VAR|g" \
	-e "s|@MAIL@|$MAIL|g" \
	-e "s|@USERNAME@|$USERNAME|g" \
	-e "s|@PASSWD@|$PASSWD|g" \
	-e "s|@DOMAIN@|$DOMAIN|g" \
	-e "s|@PASS@|$PASS|g" \
	-e "s|@PROXY_NETWORK@|$PROXY_NETWORK|g" \
	-e "s|@TRAEFIK_DASHBOARD_URL@|$TRAEFIK_DASHBOARD_URL|g" \
	-e "s|@PLEX_FQDN@|$PLEX_FQDN|g" \
	-e "s|@LIDARR_FQDN@|$LIDARR_FQDN|g" \
	-e "s|@MEDUSA_FQDN@|$MEDUSA_FQDN|g" \
	-e "s|@RTORRENT_FQDN@|$RTORRENT_FQDN|g" \
	-e "s|@RADARR_FQDN@|$RADARR_FQDN|g" \
	-e "s|@PORTAINER_FQDN@|$PORTAINER_FQDN|g" \
	-e "s|@JACKETT_FQDN@|$JACKETT_FQDN|g" \
	-e "s|@NEXTCLOUD_FQDN@|$NEXTCLOUD_FQDN|g" \
	-e "s|@TAUTULLI_FQDN@|$TAUTULLI_FQDN|g" \
	-e "s|@SYNCTHING_FQDN@|$SYNCTHING_FQDN|g" \
	-e "s|@PYLOAD_FQDN@|$PYLOAD_FQDN|g" \
	-e "s|@HEIMDALL_FQDN@|$HEIMDALL_FQDN|g" \
	"$1"
}



PROGRESSBAR() {
  local duration=${1}
printf '\n'
echo -e "${CGREEN}Patientez ...	${CEND}"
printf '\n'

    already_done() { for ((done=0; done<$elapsed; done++)); do printf "#"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
      already_done; remaining; percentage
      sleep 0.2
      clean_line
  done
  clean_line
printf '\n'
}


calcul_port () {
	HISTO=$(wc -l < "$CONFDIR"/ports.txt)
	PORT=$(( $(($1))+HISTO ))
	PORT1=$(( $(($2))+HISTO ))
}

add_appli () {
	USERNAME=$1
	NAME=$2
	INSTALL=""

	if docker ps  | grep -q ${NAME}-$USERNAME; then
		echo -e "${CGREEN}${NAME}est déjà lancé${CEND}"
		echo ""
		read -p "Appuyer sur la touche Entrer pour retourner au menu"
		clear
		logo.sh
	else
		grep ^${NAME}-$USERNAME$ /home/"$USERNAME"/appli.txt
		if  [ $? = 0 ] ; then
			echo ""
			echo -e "${CRED}Bizarre application activé mais pas lancer${CEND}"
			echo -e "${CRED}aller je relance application${CEND}"
			echo ""
			docker-compose -f /home/"$USERNAME"/docker-compose.yml up -d ${NAME}-$USERNAME
		else
			INSTALL=INSTALL
		fi
	fi
}

ins_appli () {
	USERNAME=$1
	NAME=$2

	export $(xargs </home/"$USERNAME"/.env)
	docker-compose -f /home/"$USERNAME"/docker-compose.yml up -d $LOGICIEL-$USERNAME
	docker-compose up -d $LOGICIEL 2>/dev/null
	progress-bar 20
	echo ""
	echo -e "${CGREEN}Installation de $LOGICIEL réussie${CEND}"
	echo ""
	echo "$LOGICIEL-$USERNAME" >> /home/"$USERNAME"/appli.txt
	read -p "Appuyer sur la touche Entrer pour continuer"
	clear
	logo.sh
}

del_appli () {
	sed -i '/^${NAME}-$USERNAME$/d' /home/"$USERNAME"/appli.txt
}

add_domain() {
echo -e "${CCYAN}Sous domaine de $1 ${CEND}"
DOMMAJ=$(echo "$1" | tr "[:lower:]" "[:upper:]")
read -rp "${DOMMAJ}_FQDN = " DOM_FQDN


if [ -n "$DOM_FQDN" ]
then
	export DOM_FQDN=${DOM_FQDN}.${DOMAIN}
else
	DOM_FQDN="$1".${DOMAIN}
	export DOM_FQDN
fi
}

INSTALLDOCKER () {
	whiptail --title "Installation" --msgbox "INSTALLATION DOCKER ET DOCKER-COMPOSE." 8 50
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
			whiptail --title "Installation" --msgbox "Installation docker & docker compose terminée." 8 78
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
			whiptail --title "Installation" --msgbox "Installation docker & docker compose terminée." 8 78
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
}