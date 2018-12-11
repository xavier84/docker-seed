#!/bin/bash -i

. includes/functions.sh
. includes/variable.sh

chmod 777 "${BASEDIR}"/logo.sh
"${BASEDIR}"/logo.sh

echo ""
echo ""
echo ""
PROGRESSBAR 30

if [[ "$VERSION" =~ 7.* ]] || [[ "$VERSION" =~ 8.* ]] || [[ "$VERSION" =~ 9.* ]] || [[ "$OS" = "Ubuntu" ]]; then
		if [ "$(id -u)" -ne 0 ]; then
			whiptail --title "ROOT" --msgbox "Ce script doit être exécuté en root." 8 60
			exit 1
		fi
	else
			whiptail --title "OS" --msgbox "Ce script doit être exécuté sur Debian 7/8/9 ou Ubuntu." 8 70
			exit 1
	fi



if [[ ! -d "${VOLUMES_TRAEFIK_PATH}" ]]; then
	clear
	INSTALLDOCKER

fi
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

		;;
		2)

		;;
		3)

		;;
		6)

			break
		;;
	esac
done

