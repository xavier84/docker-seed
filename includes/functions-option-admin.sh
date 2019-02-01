#!/bin/bash -i

MANAPPLIADMIN () {
	MANAGER=$(whiptail --title "Seedbox Menu" --menu "Manager applications admin:" 18 80 10 \
		"1" "Plex" \
		"2" "Tautulli" \
		"3" "Portainer" \
		"4" "Watchtower" \
		"5" "Phpmyadmin + MariaDb" \
		"6" "Cree site web par utilisateur" \
		"15" "Retour"  3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	export $(xargs <"${VOLUMES_TRAEFIK_PATH}"/domain)
	RESTART=""
	USERNAME=admin
	PROXY_NETWORK=traefik_proxy
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
				USERNAME=$(whiptail --title "Authentification portainer" --inputbox "Nom d'utilisateur pour l'authentification portainer\ninterface web  :" 9 80 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				PASSWD=$(whiptail --title "Authentification portainer" --passwordbox "Mot de passe pour l'authentification portainer\ninterface web :" 9 80 3>&1 1>&2 2>&3)
				[[ "$?" != 0 ]] && exit 1;
				htpasswd -cbs "${CONFDIR}"/admin/htpasswd "$USERNAME" "$PASSWD"
				MDP=$(sed -e 's/\$/\$$/g' "$CONFDIR"/admin/htpasswd 2>/dev/null)
				FQDN="${APPDMAJ}_FQDN"
				sed -i.bak '/services/ r '${BASEDIRDOCKER}/${APPD}'/docker-compose.yml' "${CONFDIR}"/admin/docker-compose.yml
				SEDDOCKER "${CONFDIR}"/admin/docker-compose.yml
				echo ${APPD} >> "${CONFDIR}"/admin/appli.txt
				echo ${FQDN}=${FQDNN} >> "${CONFDIR}"/admin/url.txt
				USERNAME=admin
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
		6)
			COMP=0
			TAB=()
			for USERS in $(cat "${CONFDIR}"/users.txt)
			do
				COMP=$(($COMP+1))
				TAB+=( ${USERS//\"} ${COMP//\"} )
			done
			USERNAME=$(whiptail --title "Site web" --noitem --menu \
				"Sélectionner l'Utilisateur" 15 50 6 \
				"${TAB[@]}"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			SITEWEB=$(whiptail --title "Menu options" --menu "Manager options:" 18 80 10 \
				"1" "Site vide" \
				"2" "wordpress" \
				"4" "Retour"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			export $(xargs <"${CONFDIR}"/"${USERNAME}"/.env)
			case $SITEWEB in
				1)

				;;
				2)
					APPD=wordpress
					APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
					CHECKAPPLI "${USERNAME}" "${APPD}"
					if  [ "$INSTALL" = INSTALL ] ; then
						MDPSQL="$(date +%s | sha256sum | base64 | head -c 30)"
						ADDAPPLI "${APPD}"
					fi
				;;
			esac
		;;
		15)
			return
		;;
	esac
	if  [ "$RESTART" = RESTART ] ; then
		docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d
	fi
}
