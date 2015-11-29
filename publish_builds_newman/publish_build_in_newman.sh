#!/bin/bash

source /home/xap/publish_builds_newman/env.sh
#first arg is branch, second arg is build number
BRANCH=$1
BUILD=$2
FOLDER_PATH=${WEB_FOLDER}
WEB_URI=${BASE_WEB_URI}
UPDATED_JAR_PATH=/home/xap/testing-grid/bin
echo "start publishing at $PWD ..."
echo "Arguments are BRANCH=${BRANCH}, BUILD=${BUILD}."
echo "FOLDER_PATH=${FOLDER_PATH}"
echo "WEB_URI=${WEB_URI}"

LOCAL_PATH_TO_BUILD=${FOLDER_PATH}/${BRANCH}/${BUILD}
WEB_PATH_TO_BUILD=${BASE_WEB_URI}/${BRANCH}/${BUILD}

echo "LOCAL_PATH_TO_BUILD=${LOCAL_PATH_TO_BUILD}"
echo "WEB_PATH_TO_BUILD=${WEB_PATH_TO_BUILD}"

GS_BUILD_ZIP=$(find ${LOCAL_PATH_TO_BUILD} -name '*giga*.zip')
GS_BUILD_ZIP=`basename ${GS_BUILD_ZIP}`

printf "GS_BUILD_ZIP=${GS_BUILD_ZIP}\n\n" 

export NEWMAN_BUILD_BRANCH=${BRANCH}
export NEWMAN_BUILD_NUMBER=${BUILD}

export NEWMAN_BUILD_TESTS_METADATA=${WEB_PATH_TO_BUILD}/tgrid-tests-metadata.json,${WEB_PATH_TO_BUILD}/sgtest-tests.json,${WEB_PATH_TO_BUILD}/http-session-tests.json,${WEB_PATH_TO_BUILD}/mongodb-tests.json
export NEWMAN_BUILD_SHAS_FILE=${WEB_PATH_TO_BUILD}/metadata.txt
export NEWMAN_BUILD_RESOURCES=${WEB_PATH_TO_BUILD}/testsuite-1.5.zip,${WEB_PATH_TO_BUILD}/${GS_BUILD_ZIP},${WEB_PATH_TO_BUILD}/newman-artifacts.zip,${WEB_PATH_TO_BUILD}/SGTest-sources.zip

printf "Publishing ${BRANCH}/${BUILD} to ${NEWMAN_HOST} as user: ${NEWMAN_USER_NAME}. port: ${NEWMAN_PORT}, password: ${NEWMAN_PASSWORD}.\n"
printf "NEWMAN_BUILD_BRANCH=${NEWMAN_BUILD_BRANCH}\nNEWMAN_BUILD_NUMBER=${NEWMAN_BUILD_NUMBER}\nNEWMAN_BUILD_TESTS_METADATA=${NEWMAN_BUILD_TESTS_METADATA}\nNEWMAN_BUILD_SHAS_FILE=${NEWMAN_BUILD_SHAS_FILE}\nNEWMAN_BUILD_RESOURCES=${NEWMAN_BUILD_RESOURCES}\n\n"

#java -jar newman-submitter-1.0.jar
java -cp ${UPDATED_JAR_PATH}/newman-submitter-1.0.jar com.gigaspaces.newman.NewmanBuildSubmitter

