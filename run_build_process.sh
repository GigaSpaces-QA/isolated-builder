#!/bin/bash

#variables passed to docker container from run.sh script
#export TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER='12700-5'}
export TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION='10.1.0'}
#export TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER=${TGRID_GS_PRODUCT_VERSION}-${TGRID_BUILD_NUMBER}-SNAPSHOT}
export TGRID_MILESTONE=${TGRID_MILESTONE='m10'}
export TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE='com.gigaspaces.test.blobstore*'}
export TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE=''}
export TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS='-XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -server -XX:+AggressiveOpts -showversion -XX:MaxPermSize=256m'}
export TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS='-Dcom.gs.enabled-backward-space-lifecycle-admin=true -Dcom.gs.engine.disableQuiesceMode=false'}
export TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION=${TGRID_GS_PRODUCT_VERSION} Sprint ${TGRID_MILESTONE}}
export TGRID_TARGET_JVM=${TGRID_TARGET_JVM='7_Sun8'}

#variables which are used for copying the build output to testing grid folder
export TESTING_GRID_HOME=${TESTING_GRID_HOME='/home/xap/testing-grid'}
export BUILD_DOCKER_HOME=${BUILD_DOCKER_HOME='/home/xap/docker'}
#mail recipients for CI failures
export RECIPIENTS="xap_builds@gigaspaces.com"

echo "TESTING_GRID_HOME=${TESTING_GRID_HOME}"
echo "BUILD_NUMBER=${TGRID_BUILD_NUMBER}"
echo "BUILD_DOCKER_HOME=${BUILD_DOCKER_HOME}"

#remove this comment when developing the docker file in order to build a new image of the docker container
#./build.sh

./run.sh

BUILD_STATUS=`cat sources/build_status/stat`
if [ ${BUILD_STATUS} -eq 0 ]
then
  echo "Build finished succesfully"
elif [ ${BUILD_STATUS} -lt 0 ]
then
  echo "No changes were made in xap github. exiting..."
  exit 0
else
  COUNT=`cat counter.tmp`
  echo "Build failed! check the build log in logs/${COUNT}/build.log for details"
  echo -e "CI Build Failed, check your commits\n\nBuild Log:\n`cat logs/${COUNT}/build.log`" | mail -s "CI Failure" "${RECIPIENTS}"
  exit 1
fi

if [ -d "sources/xap/core/releases" ] && [ -z "${TGRID_BUILD_NUMBER}" ]
then
    TGRID_BUILD_NUMBER=`find sources/xap/core/releases -name "testsuite-1.5.zip" -print | sed -r 's/^.*build_([0-9]*-[0-9]*).*$/\1/g'`  
else
    echo "The build was not created in the expected folder"
    exit 1
fi

echo "BUILD_NUMBER=${TGRID_BUILD_NUMBER}"

LOCAL_BUILD_DIR=${TESTING_GRID_HOME}/local-builds/${TGRID_BUILD_NUMBER}

echo "Removing local build directory if exists"

rm -rf ${LOCAL_BUILD_DIR}

echo "Creating new dir for local build in ${TESTING_GRID_HOME}/local-builds/${TGRID_BUILD_NUMBER}"

mkdir ${LOCAL_BUILD_DIR}

cp ${BUILD_DOCKER_HOME}/sources/xap/core/releases/build_${TGRID_BUILD_NUMBER}/testsuite-1.5.zip ${LOCAL_BUILD_DIR}

GS_ZIP_FILE=$(find ${BUILD_DOCKER_HOME}/sources/xap/core/releases/build_${TGRID_BUILD_NUMBER}/xap-premium/1.5 -name '*.zip')

cp -p ${GS_ZIP_FILE} ${LOCAL_BUILD_DIR}

GS_ZIP_FILE_LOCAL=$(find ${LOCAL_BUILD_DIR} -name '*giga*.zip')

echo "Extracting the build and tests zips"
pushd ${LOCAL_BUILD_DIR}
unzip testsuite-1.5.zip
unzip ${GS_ZIP_FILE_LOCAL}

echo "Cleaning the zips"
rm testsuite-1.5.zip
rm ${GS_ZIP_FILE_LOCAL}


