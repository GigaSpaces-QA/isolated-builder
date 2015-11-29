#!/bin/bash

echo "start $PWD/env.sh"
export WEB_FOLDER="/home/xap/publish_builds_newman"
export BASE_WEB_URI="http://192.168.50.63:8091"

echo "WEB_FOLDER=${WEB_FOLDER}"
echo "BASE_WEB_URI=${BASE_WEB_URI}" 

export NEWMAN_HOST="192.168.50.66"
export NEWMAN_PORT=8443
export NEWMAN_USER_NAME=root
export NEWMAN_PASSWORD=root

printf "NEWMAN_HOST=${NEWMAN_HOST}\nNEWMAN_USER_NAME=${NEWMAN_USER_NAME}\nNEWMAN_PORT=${NEWMAN_PORT}\nNEWMAN_PASSWORD=${NEWMAN_PASSWORD}\nend env.sh\n\n"
