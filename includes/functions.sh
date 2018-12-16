#!/bin/bash -i

checking_errors() {
	if [[ "$1" == "0" ]]; then
		echo -e "	${GREEN}--> Operation "$2" success !${NC}"
	else
		echo -e "	${RED}--> Operation "$2" failed !${NC}"
	fi
}

SEDDOCKER() {
sed -i \
	-e "s|@FILMS@|$FILMS|g" \
	-e "s|@SERIES@|$SERIES|g" \
	-e "s|@ANIMES@|$ANIMES|g" \
	-e "s|@MUSIC@|$MUSIC|g" \
	-e "s|@SHOME@|$SHOME|g" \
	-e "s|@VAR@|$VAR|g" \
	-e "s|@MDP@|$MDP|g" \
	-e "s|@PORT@|$PORT|g" \
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


CALCULPORT () {
	HISTO=$(wc -l < "$CONFDIR"/ports.txt)
	PORT=$(( $(($1))+HISTO ))
	PORT1=$(( $(($2))+HISTO ))
}

ADDAPPLI () {
	USERNAME=$1
	NAME=$2
	INSTALL=""

	if docker ps  | grep -q ${NAME}-$USERNAME; then
		whiptail --title "OS" --msgbox "${NAME}est déjà lancé" 8 70
	else
		grep ^${NAME} "${CONFDIR}"/"${USERNAME}"/appli.txt
		if  [ $? = 0 ] ; then
			whiptail --title "OS" --msgbox "Bizarre application activé mais paslancer \naller je relance application" 8 70
			docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d ${NAME}-$USERNAME
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
			whiptail --title "Installation" --msgbox "Installation docker & docker compose terminée." 8 78
		fi

	DOMAIN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\nles sous domaine seront gere plus tard :" 9 70 exemple.fr 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi
	TRAEFIK_DASHBOARD_URL=$(whiptail --title "Panel Traefik" --inputbox "Adresse web traefik :" 9 80 traefik.${DOMAIN} 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi
	USERNAME=$(whiptail --title "Authentification Traefik" --inputbox "Nom d'utilisateur pour l'authentification Traefik\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi
	PASSWD=$(whiptail --title "Authentification Traefik" --passwordbox "Mot de passe pour l'authentification Traefik\ninterface web :" 9 80 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi
	MAIL=$(whiptail --title "Adresse mail pour Traefik" --inputbox "Adresse mail :" 7 50 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi

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

MANUSER () {
	MANAGER=$(whiptail --title "Seedbox Menu" --menu "bienvenue sur le manager:" 18 80 10 \
		"1" "Creation utilisateur" \
		"2" "Suppression utilisateur" \
		"3" "Modification mot de passe" \
		"4" "Retour"  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]
then
	exit 1
fi
	case $MANAGER in
		1)
			DOMAIN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\nles sous domaine seront gere plus tard :" 9 70 exemple.fr 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				exit 1
			fi
			USERNAME=$(whiptail --title "Authentification Seedbox" --inputbox "Nom d'utilisateur pour l'authentification Seedbox\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				exit 1
			fi
			PASSWD=$(whiptail --title "Authentification Seedbox" --passwordbox "Mot de passe pour l'authentification Seedbox\ninterface web :" 9 80 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				exit 1
			fi
			useradd -M -s /bin/bash "$USERNAME"
			echo "${USERNAME}:${PASSWD}" | chpasswd

			mkdir -p "$CONFDIR"/"$USERNAME"
			mkdir -p /home/"$USERNAME"
			chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"
			htpasswd -cbs /etc/apache2/.htpasswd_"$USERNAME" "$USERNAME" "$PASSWD"
			MDP=$(sed -e 's/\$/\$$/g' /etc/apache2/.htpasswd_"$USERNAME" 2>/dev/null)
			SHOME=/home/"$USERNAME"
			export PASSWD
			USERMULTI=-${USERNAME}
			echo "${USERNAME}" >> "${CONFDIR}"/users.txt
			cat <<- EOF > "$CONFDIR"/"$USERNAME"/.env
			SHOME=$SHOME
			MDP=$MDP
			USERNAME=$USERNAME
			PASSWD=$PASSWD
			DOMAIN=$DOMAIN
			USERMULTI=-$USERNAME
			PROXY_NETWORK=traefik_proxy
			EOF
			if [ ! -f "$CONFDIR"/"$USERNAME"/docker-compose.yml ]; then
				cp ${BASEDIRDOCKER}/docker-compose.yml "$CONFDIR"/"$USERNAME"/docker-compose.yml
			fi

		;;
		2)
			echo sup
		;;
		3)
			echo modif
		;;
		4)
			break
		;;
	esac
}


MANAPPLI () {
	USERNAME=$(whiptail --title "Authentification Seedbox" --inputbox "Nom d'utilisateur pour l'utilisateur  :" 9 80 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		exit 1
	fi
	export $(xargs <"${CONFDIR}"/"${USERNAME}"/.env)
	ACTION=$(whiptail --title "Services manager" --checklist \
	"Please select services you want to add for $SEEDUSER (Use space to select)" 28 60 17 \
			"1" "RuTorrent" OFF \
			"2" "Medusa" OFF \
			"3" "Couchpotato" OFF \
			"4" "Portainer" OFF 3>&1 1>&2 2>&3)
		echo ""

	ACTION="$(echo $ACTION | tr -d '"')"
	for APP in $(echo $ACTION)
	do
		case $APP in
			1)
				APPD=rutorrent
				APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
				ADDAPPLI "${USERNAME}" "${APPD}"
				if  [ "$INSTALL" = INSTALL ] ; then
					RTORRENT_FQDN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPDMAJ} :" 9 70 ${APPD}${USERMULTI}.${DOMAIN} 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ $exitstatus != 0 ]
					then
						exit 1
					fi
					CALCULPORT 45000
					echo "$PORT" >> "${CONFDIR}"/ports.txt
					sed -i.bak '/services/ r '${BASEDIRDOCKER}'/'${APPD}'/docker-compose.yml' "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
					SEDDOCKER "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
					echo "${APPD}" >> "${CONFDIR}"/"${USERNAME}"/appli.txt
					echo RTORRENT_FQDN=${RTORRENT_FQDN} >> "${CONFDIR}"/"${USERNAME}"/url.txt
				fi
				;;
			2)
				APPD=medusa
				APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
				MEDUSA_FQDN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPDMAJ} :" 9 70 ${APPD}${USERMULTI}.${DOMAIN} 3>&1 1>&2 2>&3)
				exitstatus=$?
				if [ $exitstatus != 0 ]
				then
					exit 1
				fi
				sed -i.bak '/services/ r '${BASEDIRDOCKER}'/'${APPD}'/docker-compose.yml' "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
				SEDDOCKER "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
				echo "${APPD}" >> "${CONFDIR}"/"${USERNAME}"/appli.txt
				echo MEDUSA_FQDN=${MEDUSA_FQDN} >> "${CONFDIR}"/"${USERNAME}"/url.txt
				;;
			3)
				echo -e " ${BWHITE}* Couchpotato${NC}"
				cp -Rf "$BASEDIRDOCKER"/couchpotato /home/"$SEEDUSER"/dockers
				sed_docker /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/couchpotato/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				add_vhost couchpotato 5050
				;;
			4)
				echo -e " ${BWHITE}* Portainer${NC}"
				cp -Rf "$BASEDIRDOCKER"/portainer /home/"$SEEDUSER"/dockers
				sed_docker /home/"$SEEDUSER"/dockers/portainer/docker-compose.yml
				cat /home/"$SEEDUSER"/dockers/portainer/docker-compose.yml >> "$CONFDIR"/docker-compose.yml
				chown -R "$SEEDUSER": /home/"$SEEDUSER"/dockers
				;;

		esac
done

docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d
}