#!/usr/bin/env bash
echo "start $PWD/env.sh. date: `date`"

export TESTING_GRID_HOME="/home/xap/testing-grid"
export BUILD_DOCKER_HOME="/home/xap/docker"
export RECIPIENTS="xap_builds@gigaspaces.com.test-google-a.com"
export SOURCES_DIR="/home/xap/dockersources"
export LOGS_DIR="/home/xap/buildlogs"
export BRANCH_LIST_FILE="/home/xap/docker/branch_list.txt"
export COUNTER_FILE="/home/xap/docker/counter.tmp"
export PUBLISH_BUILDS_FOLDER="/home/xap/publish_builds_newman"

#Build related properties that are passed to docker container via run.sh script
export TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION='11.0.0'}
export TGRID_MILESTONE=${TGRID_MILESTONE='m7'}
export TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE='com.gigaspaces.test.blobstore*'}
export TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE=''}
export TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS='-XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -server -XX:+AggressiveOpts -showversion -XX:MaxPermSize=256m'}
export TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS='-Dcom.gs.enabled-backward-space-lifecycle-admin=true -Dcom.gs.engine.disableQuiesceMode=false'}
export TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION=${TGRID_GS_PRODUCT_VERSION} Sprint ${TGRID_MILESTONE}}
export TGRID_TARGET_JVM=${TGRID_TARGET_JVM='7_Sun8'}
export GIT_BRANCH=${GIT_BRANCH='master'}

export WEB_FOLDER="/home/xap/publish_builds_newman"
export BASE_WEB_URI="http://192.168.50.63:8091"

echo "WEB_FOLDER=${WEB_FOLDER}"
echo "BASE_WEB_URI=${BASE_WEB_URI}"

# Newman variables
export NEWMAN_HOST="192.168.50.66"
export NEWMAN_PORT=8443
export NEWMAN_USER_NAME=root
export NEWMAN_PASSWORD=root

echo "NEWMAN_HOST=${NEWMAN_HOST}"
echo "NEWMAN_PORT=${NEWMAN_PORT}"
echo ""
