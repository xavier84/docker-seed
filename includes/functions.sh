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
	-e "s|%TIMEZONE%|$TIMEZONE|g" \
	-e "s|%UID%|$USERID|g" \
	-e "s|%GID%|$GRPID|g" \
	-e "s|%PORT%|$PORT|g" \
	-e "s|%PORT1%|$PORT1|g" \
	-e "s|%USER%|$SEEDUSER|g" \
	-e "s|%EMAIL%|$CONTACTEMAIL|g" \
	-e "s|%IPADDRESS%|$IPADDRESS|g" \
	"$1"
}

calcul_port () {
	HISTO=$(wc -l < "$USERSFILE"/ports.txt)
	PORT=$(( $(($1))+HISTO ))
	PORT1=$(( $(($2))+HISTO ))
}

checking_vhost() {
	if [[ ! -f /etc/seedbox-compose/nginx/conf/"$1" ]]; then
		echo -e "	${GREEN}--> Operation "$2" success !${NC}"
	else
		echo -e "	${RED}--> Operation "$2" failed !${NC}"
	fi
}