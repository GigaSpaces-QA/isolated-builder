#!/bin/bash
. env.sh

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
  echo -e "CI Build Failed, check your commits\n\nBuild Log:\n`cat ${LOGS_DIR}/${COUNT}/build.log`" | mail -s "CI Failure" -a "From: xap@gigaspaces.com" "${RECIPIENTS}"
  exit 1
fi

if [ -d "${SOURCES_DIR}/xap/core/releases" ] && [ -z "${TGRID_BUILD_NUMBER}" ]
then
    TGRID_BUILD_NUMBER=`find ${SOURCES_DIR}/xap/core/releases -name "testsuite-1.5.zip" -print | sed -r 's/^.*build_([0-9]*-[0-9]*).*$/\1/g'`  
else
    echo "The build was not created in the expected folder"
    exit 1
fi

GS_ZIP_FILE=$(find ${SOURCES_DIR}/xap/core/releases/build_${TGRID_BUILD_NUMBER}/xap-premium/1.5 -name '*.zip')
echo "GS_ZIP_FILE=${GS_ZIP_FILE}"

GS_ZIP_FILE_MULTI_BUILDS=$(find ${GS_ZIP_FILE} -name '*giga*.zip')
echo "GS_ZIP_FILE_MULTI_BUILDS=${GS_ZIP_FILE_MULTI_BUILDS}"

PARENT_BUILDS_DIR_NAME=builds
MULTI_BUILDS_WEB_FOLDER=${PUBLISH_BUILDS_FOLDER}/${PARENT_BUILDS_DIR_NAME}
CURRENT_BUILD_FOLDER=${MULTI_BUILDS_WEB_FOLDER}/${GIT_BRANCH}/${TGRID_BUILD_NUMBER}

rm -rf ${CURRENT_BUILD_FOLDER}/${TGRID_BUILD_NUMBER}

echo "Creating build in ${CURRENT_BUILD_FOLDER}"

mkdir -p ${CURRENT_BUILD_FOLDER}

cp -f ${SOURCES_DIR}/xap/core/releases/build_${TGRID_BUILD_NUMBER}/testsuite-1.5.zip ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/newman-artifacts/newman-artifacts.zip ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/metadata/metadata.txt ${CURRENT_BUILD_FOLDER}
cp -f ${GS_ZIP_FILE_MULTI_BUILDS} ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/sgtest-metadata/sgtest-tests.json ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/sgtest-metadata/SGTest-sources.zip ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/http-session-tests-metadata/*.json ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/tgrid-tests-metadata/*.json ${CURRENT_BUILD_FOLDER}
cp -f ${SOURCES_DIR}/mongodb-tests-metadata/*.json ${CURRENT_BUILD_FOLDER}

echo "Finish creating build in ${CURRENT_BUILD_FOLDER}."
echo "MULTI_BUILDS_WEB_FOLDER=${MULTI_BUILDS_WEB_FOLDER}"
echo "GIT_BRANCH=${GIT_BRANCH}"
echo "TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER}"
echo "start running script: ${PUBLISH_BUILDS_FOLDER}/publish_build_in_newman.sh ${GIT_BRANCH} ${TGRID_BUILD_NUMBER}. log written to: ${PUBLISH_BUILDS_FOLDER}/publish.log "

${PUBLISH_BUILDS_FOLDER}/publish_build_in_newman.sh ${GIT_BRANCH} ${TGRID_BUILD_NUMBER} &> ${PUBLISH_BUILDS_FOLDER}/publish.log