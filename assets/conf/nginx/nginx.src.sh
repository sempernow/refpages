#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Create docker config objects of Nginx conf files, per mode. 
# 
# See docker service YAML.
# 
# DOMAIN default (swarm.foo) intended as localhost alias at OS hosts file.
#------------------------------------------------------------------------------

[[ $DOMAIN ]] || { echo '=== ERR : DOMAIN is UNSET';exit 0; }

echo '=== Nginx conf : Make host (dst) files from templates'

export nginx_conf='nginx.conf'
export nginx_conf_d='nginx.d.conf'

src="nginx-global-v0.0.1.conf"

printf "  %s\n" 'Docker bind mount @ nginx_conf:/etc/nginx/nginx.conf'
printf "    src: %s\n    dst: %s\n" $src $nginx_conf

sed "s/DOMAIN/${DOMAIN}/g" ${0%/*}/$src \
	|sed '/^ *#/d' |sed '/^\s*$/d' > ${0%/*}/${APP_SERVICE_MODE}/$nginx_conf
	#... strip comment and blank lines

src="${APP_SERVICE_MODE}/nginx.src.upstream.conf"

printf "  %s\n" 'Docker bind mount @ nginx_conf_d:/etc/nginx/default.conf'
printf "    src: %s\n    dst: %s\n" $src $nginx_conf_d

sed "s/DOMAIN/${DOMAIN}/g" ${0%/*}/$src \
	|sed "s/ONION/${ONION}/g" \
	|sed "s/PORT_RPX/${PORT_RPX:-8888}/g" \
	|sed "s/PORT_AOA/${PORT_AOA:-3333}/g" \
	|sed "s/PORT_API/${PORT_API:-3000}/g" \
	|sed "s/PORT_PWA/${PORT_PWA:-3030}/g" \
	|sed "s/REPLICAS_AOA/${REPLICAS_AOA:-1}/g" \
	|sed "s/REPLICAS_API/${REPLICAS_API:-1}/g" \
	|sed "s/REPLICAS_PWA/${REPLICAS_PWA:-1}/g" \
	|sed "s/KEEPALIVE_AOA/${KEEPALIVE_AOA:-2}/g" \
	|sed "s/KEEPALIVE_API/${KEEPALIVE_API:-2}/g" \
	|sed "s/KEEPALIVE_PWA/${KEEPALIVE_PWA:-2}/g" \
	|sed '/^ *#/d' |sed '/^\s*$/d' > ${0%/*}/${APP_SERVICE_MODE}/$nginx_conf_d
	#... strip comment and blank lines

# Try to remove existing ngx_* docker configs; warn on fail, but continue.
[[ $( docker config ls -q --filter Name=ngx_ ) ]] && {
	echo '=== Nginx conf : Remove old : docker config'
	docker config rm $( docker config ls -q --filter Name=ngx_ ) 2>/dev/null
	[[ $( docker config ls -q --filter Name=ngx_ ) ]] && { 
		echo 'WARN : some ngx_* are IN USE'; 
	}
}

echo '=== Nginx conf : Create new : docker config'
ver="$(date '+%Y-%m-%dT%H.%M.%SZ')"

docker config create \
	--label ver=$ver \
	--label src=$nginx_conf \
	'ngx_conf' ${0%/*}/${APP_SERVICE_MODE}/$nginx_conf

docker config create \
	--label ver=$ver \
	--label src=$nginx_conf_d \
	'ngx_conf_d' ${0%/*}/${APP_SERVICE_MODE}/$nginx_conf_d

exit 0
