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
	HISTO=$(wc -l < "$CONFDIR"/ports.txt)
	PORT=$(( $(($1))+HISTO ))
	PORT1=$(( $(($2))+HISTO ))
}

add_vhost() {
	if [[ ! -f "$CONFDIR"/nginx/conf/"$1" ]]; then
		cp "$BASEDIRDOCKER"/"$1"/"$1".conf "$CONFDIR"/nginx/conf/
		sed_docker "$CONFDIR"/nginx/conf/"$1".conf
		sed -i '$d' "$CONFDIR"/nginx/sites-enabled/seedbox.conf
		cat <<- EOF >> "$CONFDIR"/nginx/sites-enabled/seedbox.conf
		include /conf.d/$1.conf;
		}
		EOF
	else
		sed -i '$d' "$CONFDIR"/nginx/conf/"$1".conf
			cat <<- EOF >> "$CONFDIR"/nginx/conf/"$1".conf
			                if (\$remote_user = "%USER%") {
		                        proxy_pass http://"$1"-%USER%:"$2";
		                        break;
			               }
			      }
			EOF
	fi
}