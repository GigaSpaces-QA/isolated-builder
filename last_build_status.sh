#!/bin/bash
. env.sh
BUILD_STATUS=`cat ${SOURCES_DIR}/build_status/stat`
BUILD_NUM=`cat ${COUNTER_FILE}`
if [ ${BUILD_STATUS} -eq 0 ]
then
  echo "Last Build finished succesfully"
elif [ ${BUILD_STATUS} -lt 0 ]
then
  echo "No changes were made"
else
  echo "Build Failed!"
fi
 echo "Build number: ${BUILD_NUM}"


