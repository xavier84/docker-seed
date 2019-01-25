#!/bin/bash -i

MANOPTION () {
		MANAGER=$(whiptail --title "Menu options" --menu "Manager options:" 18 80 10 \
		"1" "Mount dossier home dans nextcloud" \
		"2" "en cour" \
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
		2)
			DEV
		;;
		3)
			DEV
		;;
		4)
			return
		;;
	esac
}
