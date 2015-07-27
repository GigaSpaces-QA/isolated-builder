#!/bin/bash
. env.sh
#variables passed to docker container from run.sh script
#export TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER='12700-5'}
export TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION='10.2.0'}
#export TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER=${TGRID_GS_PRODUCT_VERSION}-${TGRID_BUILD_NUMBER}-SNAPSHOT}
export TGRID_MILESTONE=${TGRID_MILESTONE='ga'}
export TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE='com.gigaspaces.test.blobstore*'}
export TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE=''}
export TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS='-XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -server -XX:+AggressiveOpts -showversion -XX:MaxPermSize=256m'}
export TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS='-Dcom.gs.enabled-backward-space-lifecycle-admin=true -Dcom.gs.engine.disableQuiesceMode=false'}
export TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION=${TGRID_GS_PRODUCT_VERSION} Sprint ${TGRID_MILESTONE}}
export TGRID_TARGET_JVM=${TGRID_TARGET_JVM='7_Sun8'}

GIT_BRANCH=${GIT_BRANCH='master'}
#remove this comment when developing the docker file in order to build a new image of the docker container
#./build.sh

./run.sh

BUILD_STATUS=`cat ${SOURCES_DIR}/build_status/stat`
if [ ${BUILD_STATUS} -eq 0 ]
then
  echo "Build finished succesfully"
elif [ ${BUILD_STATUS} -lt 0 ]
then
  echo "No changes were made in xap github. exiting..."
  exit 0
else
  COUNT=`cat ${COUNTER_FILE}`
  echo "Build failed! check the build log in ${LOGS_DIR}/${COUNT}/build.log for details"
  echo -e "CI Build Failed, check your commits\n\nBuild Log:\n`cat ${LOGS_DIR}/${COUNT}/build.log`" | mail -s "CI Failure" "${RECIPIENTS}"
  exit 1
fi

if [ -d "${SOURCES_DIR}/xap/core/releases" ] && [ -z "${TGRID_BUILD_NUMBER}" ]
then
    TGRID_BUILD_NUMBER=`find ${SOURCES_DIR}/xap/core/releases -name "testsuite-1.5.zip" -print | sed -r 's/^.*build_([0-9]*-[0-9]*).*$/\1/g'`  
else
    echo "The build was not created in the expected folder"
    exit 1
fi

echo "BUILD_NUMBER=${TGRID_BUILD_NUMBER}"

LOCAL_BUILD_DIR=${TESTING_GRID_HOME}/local-builds/${GIT_BRANCH}/${TGRID_BUILD_NUMBER}

echo "Removing local build directory if exists"

rm -rf ${LOCAL_BUILD_DIR}

echo "Creating new dir for local build in ${LOCAL_BUILD_DIR}"

mkdir -p ${LOCAL_BUILD_DIR}

cp ${SOURCES_DIR}/xap/core/releases/build_${TGRID_BUILD_NUMBER}/testsuite-1.5.zip ${LOCAL_BUILD_DIR}

GS_ZIP_FILE=$(find ${SOURCES_DIR}/xap/core/releases/build_${TGRID_BUILD_NUMBER}/xap-premium/1.5 -name '*.zip')

cp -p ${GS_ZIP_FILE} ${LOCAL_BUILD_DIR}

GS_ZIP_FILE_LOCAL=$(find ${LOCAL_BUILD_DIR} -name '*giga*.zip')

echo "Extracting the build and tests zips and copying newman resources to ${WEB_FOLDER}/pending_build"
pushd ${LOCAL_BUILD_DIR}
# copy resources that are used for newman submitter to a folder which is served in http web server
rm -rf ${WEB_FOLDER}/pending_build/*
cp -f testsuite-1.5.zip ${WEB_FOLDER}/pending_build
cp -f metadata.txt ${WEB_FOLDER}/pending_build
cp -f ${SOURCES_DIR}/newman-artifacts/newman-artifacts.zip ${WEB_FOLDER}/pending_build
cp -f ${SOURCES_DIR}/metadata/metadata.txt ${WEB_FOLDER}/pending_build
cp -f ${GS_ZIP_FILE_LOCAL} ${WEB_FOLDER}/pending_build
cp -f ${SOURCES_DIR}/sgtest-jar/SGTest*.jar ${WEB_FOLDER}/pending_build

unzip testsuite-1.5.zip
unzip ${GS_ZIP_FILE_LOCAL}

echo "Cleaning the zips"
rm testsuite-1.5.zip
rm ${GS_ZIP_FILE_LOCAL}
 


