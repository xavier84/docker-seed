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
	-e "s|@PORT1@|$PORT1|g" \
	-e "s|@MAIL@|$MAIL|g" \
	-e "s|@USERNAME@|$USERNAME|g" \
	-e "s|@USERNEXT@|$USERNEXT|g" \
	-e "s|@MDPNEXT@|$MDPNEXT|g" \
	-e "s|@PASSWD@|$PASSWD|g" \
	-e "s|@DOMAIN@|$DOMAIN|g" \
	-e "s|@PASS@|$PASS|g" \
	-e "s|@PUID@|$PUID|g" \
	-e "s|@PGID@|$PGID|g" \
	-e "s|@PROXY_NETWORK@|$PROXY_NETWORK|g" \
	-e "s|@TRAEFIK_DASHBOARD_URL@|$TRAEFIK_DASHBOARD_URL|g" \
	-e "s|@${FQDN}@|$FQDNN|g" \
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

DEV () {
	whiptail --title "DEV" --msgbox "En cour de developpement." 8 50
}

ADDFTP () {
	docker exec -i ftp /bin/bash << EOX
	( echo ${PASSWD} ; echo ${PASSWD} )|pure-pw useradd ${USERNAME} -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/${USERNAME}
EOX
}

DELFTP () {
	docker exec -i ftp /bin/bash << EOC
    pure-pw userdel ${USERNAME} -f /etc/pure-ftpd/passwd/pureftpd.passwd
EOC
}

CHECKAPPLI () {
	USERNAME=$1
	NAME=$2
	INSTALL=""

	if docker ps  | grep -q ${NAME}-${USERNAME}; then
		whiptail --title "OS" --msgbox "${NAME} est déjà lancé pour ${USERNAME}." 8 70
	else
		grep ^${NAME}$ "${CONFDIR}"/"${USERNAME}"/appli.txt
		if  [ $? = 0 ] ; then
			whiptail --title "OS" --msgbox "Bizarre, ${NAME} activé mais pas lancer \n je relance application" 8 70
			#RESTART="RESTART"
			docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d ${NAME}-"${USERNAME}"
		else
			INSTALL=INSTALL
		fi
	fi
}

ADDAPPLI () {
	APPD=$1
	FQDNN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPDMAJ} :" 9 70 ${APPD}${USERMULTI}.${DOMAIN} 3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	FQDN="${APPDMAJ}_FQDN"
	sed -i.bak '/services/ r '${BASEDIRDOCKER}'/'${APPD}'/docker-compose.yml' "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
	SEDDOCKER "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
	echo "${APPD}" >> "${CONFDIR}"/"${USERNAME}"/appli.txt
	echo ${FQDN}=${FQDNN} >> "${CONFDIR}"/"${USERNAME}"/url.txt
	RESTART="RESTART"

}

INSTALLDOCKER () {

	whiptail --title "Installation" --msgbox "INSTALLATION DOCKER ET DOCKER-COMPOSE." 8 50
	if [ "$OS" = "Ubuntu" ]
		then
			apt update && apt upgrade -y
			apt install apache2-utils curl unzip cpufrequtils -y
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
			apt install apache2-utils curl unzip cpufrequtils -y
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
	[[ "$?" != 0 ]] && exit 1;
	TRAEFIK_DASHBOARD_URL=$(whiptail --title "Panel Traefik" --inputbox "Adresse web traefik :" 9 80 traefik.${DOMAIN} 3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	USERNAME=$(whiptail --title "Authentification Traefik" --inputbox "Nom d'utilisateur pour l'authentification Traefik\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	PASSWD=$(whiptail --title "Authentification Traefik" --passwordbox "Mot de passe pour l'authentification Traefik\ninterface web :" 9 80 3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	MAIL=$(whiptail --title "Adresse mail pour Traefik" --inputbox "Adresse mail :" 7 50 3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;

	#gouverneur
	cpufreq-set -r -g performance
	if [ ! -f /etc/default/cpufrequtils ]; then
		cat <<- EOF > /etc/default/cpufrequtils
		ENABLE="true"
		GOVERNOR="performance"
		MAX_SPEED="0"
		MIN_SPEED="0"
		EOF
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

	mkdir -p "${CONFDIR}"
	touch "${CONFDIR}"/users.txt
	touch "${CONFDIR}"/ports.txt
	sed -i "s/Subsystem[[:blank:]]sftp[[:blank:]]\/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g;" /etc/ssh/sshd_config
	sed -i "s/UsePAM/#UsePAM/g;" /etc/ssh/sshd_config
	systemctl restart ssh
	echo 'export PATH=$PATH:/opt/seedbox' >> /home/user/.bashrc
	source /root/.bashrc

}

MANUSER () {
	MANAGER=$(whiptail --title "Seedbox Menu" --menu "bienvenue sur le manager:" 18 80 10 \
		"1" "Creation utilisateur" \
		"2" "Suppression utilisateur" \
		"3" "Modification mot de passe" \
		"4" "Retour"  3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	case $MANAGER in
		1)
			DOMAIN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\nles sous domaine seront gere plus tard :" 9 70 exemple.fr 3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			while :; do
				TESTUSER=$(whiptail --title "Authentification Seedbox" --inputbox "Nom d'utilisateur pour l'authentification Seedbox\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				grep -w "$TESTUSER" /etc/passwd &> /dev/null
				if [ $? -eq 1 ]; then
					if [[ "$TESTUSER" =~ ^[a-z0-9]{3,}$ ]]; then
						USERNAME="$TESTUSER"
						break
					else
						whiptail --title "Installation" --msgbox "Le nom de votre utilisateur doit être en minuscule,\nde plus de 3 lettres et sans caractères spéciaux." 10 60
					fi
				else
					whiptail --title "Installation" --msgbox "Erreur cet utilisateur existe déjà." 8 50
				fi
			done
			PASSWD=$(whiptail --title "Authentification Seedbox" --passwordbox "Mot de passe pour l'authentification Seedbox\ninterface web :" 9 80 3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			useradd -M -s /bin/bash "$USERNAME"
			echo "${USERNAME}:${PASSWD}" | chpasswd

			mkdir -p "$CONFDIR"/"${USERNAME}"
			touch "${CONFDIR}"/"${USERNAME}"/appli.txt
			mkdir -p /home/"${USERNAME}"
			chown -R "${USERNAME}":"${USERNAME}" /home/"${USERNAME}"
			chown  root:"${USERNAME}" /home/"${USERNAME}"
			chmod 755 /home/"${USERNAME}"
			htpasswd -cbs "${CONFDIR}"/"${USERNAME}"/htpasswd "$USERNAME" "$PASSWD"
			MDP=$(sed -e 's/\$/\$$/g' "$CONFDIR"/"$USERNAME"/htpasswd 2>/dev/null)
			SHOME=/home/"$USERNAME"
			export PASSWD
			USERMULTI=-${USERNAME}
			PUID=$(id -u $USERNAME)
			PGID=$(id -g $USERNAME)
			cat <<- EOF >> /etc/ssh/sshd_config
				Match User ${USERNAME}
				ChrootDirectory /home/${USERNAME}
			EOF
			systemctl restart ssh
			echo "${USERNAME}" >> "${CONFDIR}"/users.txt
			ADDFTP
			cat <<- EOF > "$CONFDIR"/"$USERNAME"/.env
			SHOME=$SHOME
			MDP=$MDP
			USERNAME=$USERNAME
			PASSWD=$PASSWD
			DOMAIN=$DOMAIN
			USERMULTI=-$USERNAME
			PUID=$PUID
			PGID=$PGID
			PROXY_NETWORK=traefik_proxy
			EOF
			if [ ! -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml ]; then
				cp ${BASEDIRDOCKER}/docker-compose.yml "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
			fi

		;;
		2)
			if [[ -s "${CONFDIR}"/users.txt ]]; then
				COMP=0
				TAB=()
				for USERS in $(cat "${CONFDIR}"/users.txt)
				do
					COMP=$(($COMP+1))
					TAB+=( ${USERS//\"} ${COMP//\"} )
				done
				USERNAME=$(whiptail --title "Suppression" --noitem --menu \
					"Sélectionner l'Utilisateur" 15 50 6 \
					"${TAB[@]}"  3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				DATE="$(date '+%d-%m-%y_%Hh%Mm%Ss')"
				if (whiptail --title "Suppression" --yesno "Veux-tu gardé le dossier: /home/"${USERNAME}"/rutorrent/downloads ? \n\n si "oui" il sera deplacé dans /home/backup/"${USERNAME}-${DATE}"" 15 60 3>&1 1>&2 2>&3); then
					SAVE=oui
				else
					SAVE=non
				fi
				if  [[ "$SAVE" = "oui" ]]; then
					mkdir -p /home/backup/"${USERNAME}-${DATE}"
					mv /home/"${USERNAME}"/rutorrent/downloads/ /home/backup/"${USERNAME}-${DATE}"
				fi
				docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs
				DELFTP
				userdel -r -f "${USERNAME}"
				sed -i "/^${USERNAME}$/d" "${CONFDIR}"/users.txt
				rm -rf "${CONFDIR}"/"${USERNAME}"
			else
				whiptail --title "user" --msgbox "Aucun uilisateur" 8 60
			fi
		;;
		3)
			COMP=0
			TAB=()
			for USERS in $(cat "${CONFDIR}"/users.txt)
			do
				COMP=$(($COMP+1))
				TAB+=( ${USERS//\"} ${COMP//\"} )
			done
			USERNAME=$(whiptail --title "Gestion des applications" --noitem --menu \
				"Sélectionner l'Utilisateur" 15 50 6 \
				"${TAB[@]}"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			PASSWD=$(whiptail --title "Authentification Seedbox" --passwordbox "Mot de passe pour l'authentification Seedbox\ninterface web :" 9 80 3>&1 1>&2 2>&3)
			htpasswd -cbs "${CONFDIR}"/"${USERNAME}"/htpasswd "$USERNAME" "$PASSWD"
			MDP=$(sed -e 's/\$/\$$/g' "$CONFDIR"/"$USERNAME"/htpasswd 2>/dev/null)
			#sed -i "s|PASSWD=\(.*\)|PASSWD=audrey|g;" .env
			sed -i "s|PASSWD=\(.*\)|PASSWD=${PASSWD}|g;" "$CONFDIR"/"$USERNAME"/.env
			sed -i "s|MDP=\(.*\)|MDP=${MDP}|g;" "$CONFDIR"/"$USERNAME"/.env
			sed -i "s|traefik.frontend.auth.basic=\(.*\)|traefik.frontend.auth.basic=${MDP}|g;" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
			docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs
			docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d

		;;
		4)
			return
		;;
	esac
}

MANAPPLIADMIN () {
	MANAGER=$(whiptail --title "Seedbox Menu" --menu "Manager applications admin:" 18 80 10 \
		"1" "Plex" \
		"2" "Tautulli" \
		"3" "Portainer" \
		"4" "Watchtower" \
		"5" "Phpmyadmin + MariaDb" \
		"6" "Retour"  3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	RESTART=""
	if [ ! -f "$CONFDIR"/admin/docker-compose.yml ]; then
				mkdir -p "$CONFDIR"/admin
				touch "${CONFDIR}"/admin/appli.txt
				cp ${BASEDIRDOCKER}/docker-compose.yml "$CONFDIR"/admin/docker-compose.yml
			fi
	case $MANAGER in
		1)
			APPD=plex
			APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
			grep ^${APPD}$ "${CONFDIR}"/admin/appli.txt
			if  [ $? != 0 ] ; then
				FQDNN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPD} :" 9 70 ${APPD}.${DOMAIN} 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				FQDN="${APPDMAJ}_FQDN"
				CLAIM=$(whiptail --title "CLAIM" --inputbox "Un token est nécéssaire pour AUTHENTIFIER le serveur Plex .Pour obtenir un identifiant CLAIM, allez à cette adresse et copier le dans le terminal. \nhttps://www.plex.tv/claim/ " 12 70 claim- 3>&1 1>&2 2>&3)
				sed -i.bak '/services/ r '${BASEDIRDOCKER}/${APPD}'/docker-compose.yml' "${CONFDIR}"/admin/docker-compose.yml
				sed -i "s|@${FQDN}@|$FQDNN|g;" "${CONFDIR}"/admin/docker-compose.yml
				sed -i "s|@CLAIM@|$CLAIM|g;" "${CONFDIR}"/admin/docker-compose.yml
				echo ${APPD} >> "${CONFDIR}"/admin/appli.txt
				echo ${FQDN}=${FQDNN} >> "${CONFDIR}"/admin/url.txt
				RESTART="RESTART"
			else
				whiptail --title "admin" --msgbox "${APPDMAJ} deja installer" 8 50
			fi
		;;
		2)
			APPD=tautulli
			APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
			grep ^${APPD}$ "${CONFDIR}"/admin/appli.txt
			if  [ $? != 0 ] ; then
				FQDNN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPD} :" 9 70 ${APPD}.${DOMAIN} 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				USERNAME=$(whiptail --title "Authentification tautulli" --inputbox "Nom d'utilisateur pour l'authentification tautulli\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				PASSWD=$(whiptail --title "Authentification tautulli" --passwordbox "Mot de passe pour l'authentification tautulli\ninterface web :" 9 80 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				htpasswd -cbs "${CONFDIR}"/admin/htpasswd "$USERNAME" "$PASSWD"
				MDP=$(sed -e 's/\$/\$$/g' "$CONFDIR"/admin/htpasswd 2>/dev/null)
				FQDN="${APPDMAJ}_FQDN"
				sed -i.bak '/services/ r '${BASEDIRDOCKER}/${APPD}'/docker-compose.yml' "${CONFDIR}"/admin/docker-compose.yml
				SEDDOCKER "${CONFDIR}"/admin/docker-compose.yml
				echo ${APPD} >> "${CONFDIR}"/admin/appli.txt
				echo ${FQDN}=${FQDNN} >> "${CONFDIR}"/admin/url.txt
				RESTART="RESTART"
			else
				whiptail --title "admin" --msgbox "${APPDMAJ} deja installer" 8 50
			fi
		;;
		3)
			APPD=portainer
			APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
			grep ^${APPD}$ "${CONFDIR}"/admin/appli.txt
			if  [ $? != 0 ] ; then
				FQDNN=$(whiptail --title "Nom de domaine" --inputbox "Nom de domaine\n${APPD} :" 9 70 ${APPD}.${DOMAIN} 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				FQDN="${APPDMAJ}_FQDN"
				sed -i.bak '/services/ r '${BASEDIRDOCKER}/${APPD}'/docker-compose.yml' "${CONFDIR}"/admin/docker-compose.yml
				sed -i "s|@${FQDN}@|$FQDNN|g;" "${CONFDIR}"/admin/docker-compose.yml
				echo ${APPD} >> "${CONFDIR}"/admin/appli.txt
				echo ${FQDN}=${FQDNN} >> "${CONFDIR}"/admin/url.txt
				RESTART="RESTART"
			else
				whiptail --title "admin" --msgbox "${APPDMAJ} deja installer" 8 50
			fi
		;;
		4)
			APPD=watchtower
			APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
			grep ^${APPD}$ "${CONFDIR}"/admin/appli.txt
			if  [ $? != 0 ] ; then
				sed -i.bak '/services/ r '${BASEDIRDOCKER}/${APPD}'/docker-compose.yml' "${CONFDIR}"/admin/docker-compose.yml
				echo ${APPD} >> "${CONFDIR}"/admin/appli.txt
				RESTART="RESTART"
			else
				whiptail --title "admin" --msgbox "${APPDMAJ} deja installer" 8 50
			fi
		;;
		5)
			DEV
		;;
		5)
			return
		;;
	esac
	if  [ "$RESTART" = RESTART ] ; then
		docker-compose -f "${CONFDIR}"/admin/docker-compose.yml up -d
	fi
}

MANOPTION () {
		MANAGER=$(whiptail --title "Menu options" --menu "Manager options:" 18 80 10 \
		"1" "Mount dossier home dans nextcloud" \
		"2" "Suppression utilisateur" \
		"3" "Modification mot de passe" \
		"4" "Retour"  3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	case $MANAGER in
		1)
			COMP=0
			TAB=()
			for USERS in $(cat "${CONFDIR}"/users.txt)
			do
				COMP=$(($COMP+1))
				TAB+=( ${USERS//\"} ${COMP//\"} )
			done
			USERNAME=$(whiptail --title "Gestion des applications" --noitem --menu \
				"Sélectionner l'Utilisateur" 15 50 6 \
				"${TAB[@]}"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			export $(xargs <"${CONFDIR}"/"${USERNAME}"/.env)
			if docker ps  | grep -q nextcloud-${USERNAME}; then
				COMP1=0
				FIN=0
				while [ "$FIN" != "1" ]
				do
				if docker exec -t nextcloud-${USERNAME} su -c "ps aux | grep -v grep | grep nginx"
				then
					sleep 5
					docker exec -t nextcloud-${USERNAME} su -c "adduser -S ${USERNAME} -u ${PUID}"
					docker exec -t nextcloud-${USERNAME} su -s /bin/sh ${USERNAME} -c "/usr/bin/php /nextcloud/occ files:scan --all"
					docker exec -t nextcloud-${USERNAME} su -s /bin/sh ${USERNAME} -c "/usr/bin/php /nextcloud/occ app:list"
					docker exec -t nextcloud-${USERNAME} su -s /bin/sh ${USERNAME} -c "/usr/bin/php /nextcloud/occ app:enable files_external"
					cp ${BASEDIRDOCKER}/nextcloud/mount.json /home/"${USERNAME}"/docker/nextcloud/apps/mount-${USERNAME}.json
					SEDDOCKER /home/"${USERNAME}"/docker/nextcloud/apps/mount-${USERNAME}.json
					docker exec -t nextcloud-${USERNAME} su -s /bin/sh ${USERNAME} -c "/usr/bin/php /nextcloud/occ files_external:import /apps2/mount-${USERNAME}.json"
					rm -f /home/"${USERNAME}"/docker/nextcloud/apps/mount-${USERNAME}.json
					FIN=1
				else
					COMP1=$(($COMP1+1))
					echo -n "$COMP1$TMP+*"
					sleep 1
				fi
				done
			else
				whiptail --title "nextcloud" --msgbox "Pas de nextcloud pour ${USERNAME}" 8 70
			fi

		;;
		3)
			DEV
		;;
		4)
			return
		;;
	esac
}

MANSAVE () {
	HISTO=$(wc -l < "$CONFDIR"/ports.txt)
	PORT=$(( $(($1))+HISTO ))
	PORT1=$(( $(($2))+HISTO ))
}
