#!/bin/bash
export TESTING_GRID_HOME="/home/xap/testing-grid"
export BUILD_DOCKER_HOME="/home/xap/docker"
#export RECIPIENTS="xap_builds@gigaspaces.com"
export RECIPIENTS="xap_builds@gigaspaces.com.test-google-a.com"
export SOURCES_DIR="/home/xap/dockersources"
export LOGS_DIR="/home/xap/buildlogs"
export WEB_FOLDER="/home/xap/build-web"
export BRANCH_LIST_FILE="/home/xap/docker/branch_list.txt"
export COUNTER_FILE="/home/xap/docker/counter.tmp"
export PUBLISH_BUILDS_FOLDER="/home/xap/publish_builds_newman"

#Build related properties that are passed to docker container via run.sh script
export TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION='11.0.0'}
#comment the next 2 lines and switch version to 11.0.0 and milestone to m1
#export TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER=${TGRID_GS_PRODUCT_VERSION}-${TGRID_BUILD_NUMBER}-RELEASE}
#export TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER='13800'}
export TGRID_MILESTONE=${TGRID_MILESTONE='m5'}
export TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE='com.gigaspaces.test.blobstore*'}
export TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE=''}
export TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS='-XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -server -XX:+AggressiveOpts -showversion -XX:MaxPermSize=256m'}
export TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS='-Dcom.gs.enabled-backward-space-lifecycle-admin=true -Dcom.gs.engine.disableQuiesceMode=false'}
export TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION=${TGRID_GS_PRODUCT_VERSION} Sprint ${TGRID_MILESTONE}}
export TGRID_TARGET_JVM=${TGRID_TARGET_JVM='7_Sun8'}
export GIT_BRANCH=${GIT_BRANCH='master'}
