#!/bin/bash -i

MANAPPLI () {
	MANAGER=$(whiptail --title "Seedbox Menu" --menu "bienvenue sur le manager:" 18 80 10 \
		"1" "Ajout applications" \
		"2" "Suppression applications" \
		"3" "Modification applications" \
		"4" "Retour"  3>&1 1>&2 2>&3)
	[[ "$?" != 0 ]] && exit 1;
	RESTART=""
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
			COMP1=0
			TAB1=()
			for LAPP1 in $(cat "${BASEDIR}"/includes/listeapp.txt)
			do
				COMP1=$(($COMP1+1))
				TAB1+=( ${LAPP1//\"} ${COMP1//\"} OFF)
			done
			ACTION=$(whiptail --title "Choix des applications" --checklist \
				"Utiliser \"la barre espace\" pour selectionner une/des application/s, puis TAB ou entrer pour valider" 28 60 17 \
				"${TAB1[@]}"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			ACTION="$(echo $ACTION | tr -d '"')"
			for APP in $(echo $ACTION)
			do
				case $APP in
				rutorrent)
						APPD=rutorrent
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							CALCULPORT 45000
							echo "$PORT" >> "${CONFDIR}"/ports.txt
							ADDAPPLI "${APPD}"
						fi
						;;
				medusa)
						APPD=medusa
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				heimdall)
						APPD=heimdall
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				pyload)
						APPD=pyload
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				jackett)
						APPD=jackett
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				syncthing)
						APPD=syncthing
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							CALCULPORT 22000 21027
							echo "$PORT" >> "${CONFDIR}"/ports.txt
							ADDAPPLI "${APPD}"
						fi
						;;
				nextcloud)
						APPD=nextcloud
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							USERNEXT=$(whiptail --title "Authentification nextcloud" --inputbox "Nom d'utilisateur pour l'Admin nextcloud :" 9 80 3>&1 1>&2 2>&3)
							[[ "$?" != 0 ]] && exit 1;
							MDPNEXT=$(whiptail --title "Authentification nextcloud" --passwordbox "Mot de passe pour l'Admin nextcloud :" 9 80 3>&1 1>&2 2>&3)
							[[ "$?" != 0 ]] && exit 1;
							ADDAPPLI "${APPD}"
						fi
						;;
				hydra)
						APPD=hydra
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				radarr)
						APPD=radarr
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
				lidarr)
						APPD=lidarr
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						CHECKAPPLI "${USERNAME}" "${APPD}"
						if  [ "$INSTALL" = INSTALL ] ; then
							ADDAPPLI "${APPD}"
						fi
						;;
					40)

						;;

				esac
			done
		;;
		2)
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
			COMP1=0
			TAB1=()
			for USERS1 in $(cat "${CONFDIR}"/"${USERNAME}"/appli.txt)
			do
				COMP1=$(($COMP1+1))
				TAB1+=( ${USERS1//\"} ${COMP1//\"} OFF)
			done
			ACTION=$(whiptail --title "Choix des applications" --checklist \
				"Utiliser \"la barre espace\" pour selectionner une/des application/s, puis TAB ou entrer pour valider" 28 60 17 \
				"${TAB1[@]}"  3>&1 1>&2 2>&3)
			[[ "$?" != 0 ]] && exit 1;
			export $(xargs <"${CONFDIR}"/"${USERNAME}"/.env)
			ACTION="$(echo $ACTION | tr -d '"')"
			for APP in $(echo $ACTION)
			do
				case $APP in
					rutorrent)
						APPD=rutorrent
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					medusa)
						APPD=medusa
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					heimdall)
						APPD=heimdall
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					pyload)
						APPD=pyload
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					jackett)
						APPD=jackett
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					syncthing)
						APPD=syncthing
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					nextcloud)
						APPD=nextcloud
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					hydra)
						APPD=hydra
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					radarr)
						APPD=radarr
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					lidarr)
						APPD=lidarr
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
					wordpress)
						APPD=wordpress
						APPDMAJ=$(echo "$APPD" | tr "[:lower:]" "[:upper:]")
						docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml rm -fs "${APPD}"-"${USERNAME}"
						sed -i "/^${APPD}$/d" "${CONFDIR}"/"${USERNAME}"/appli.txt
						sed -i "/^${APPDMAJ_FQDN}/d" "${CONFDIR}"/"${USERNAME}"/url.txt
						sed -i "/#start"$APPD"/,/#end"$APPD"/d" "${CONFDIR}"/"${USERNAME}"/docker-compose.yml
						rm -rf /home/"${USERNAME}"/docker/"${APPD}"
						#RESTART="RESTART"
						;;
				esac
			done
		;;
		3)
			DEV
		;;
		4)
			return
		;;
	esac

	if  [ "$RESTART" = RESTART ] ; then
		docker-compose -f "${CONFDIR}"/"${USERNAME}"/docker-compose.yml up -d
	fi
}

