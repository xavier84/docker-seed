#!/bin/bash -i

source /opt/seedbox/includes/functions.sh
source /opt/seedbox/includes/functions-app.sh
source /opt/seedbox/includes/functions-option.sh
source /opt/seedbox/includes/functions-option-admin.sh
source /opt/seedbox/includes/variable.sh

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
	INSTALLDOCKER

fi
clear
while :; do
MANAGER=$(whiptail --title "Seedbox Menu" --menu "bienvenue sur le manager:" 18 80 10 \
		"1" "Gestion des uilisateurs" \
		"2" "Gestion des applications" \
		"3" "Gestion des applications admin" \
		"4" "Gestion des options" \
		"5" "Gestion des sauvegarde/restauration" \
		"6" "Suppression de Seedbox" \
		"15" "Sortir"  3>&1 1>&2 2>&3)
[[ "$?" != 0 ]] && exit 1;

	case $MANAGER in
		1)
			MANUSER
		;;
		2)
			if [[ -s "${CONFDIR}"/users.txt ]]; then
				MANAPPLI
			else
				whiptail --title "user" --msgbox "Cree un uilisateur avant" 8 60
			fi
		;;
		3)
			MANAPPLIADMIN
		;;
		4)
			MANOPTION
		;;
		5)
			MANSAVE
		;;
		6)
			MANDEL
		;;
		15)
			exit 1
		;;
	esac
done

