#!/bin/bash

FORCE=false
SOURCES_CHANGED=false
SOURCES_DIR='/sources'
BUILD_PREFIX='12800-'

mkdir -p -v ${SOURCES_DIR}/build_status

  function check_git_changes {
   pushd $1
   git clean -fdx
   local head=`git rev-parse HEAD`
   git fetch
   local origin=`git rev-parse origin/master`
   if [ "$head" == "$origin" ]
   then
     echo "sources were not changed in $1, no point building a new build."
     echo "git sha is: ${head}"
     if [ "$FORCE" = true ]
     then
         echo "Warning force flag is on"
         SOURCES_CHANGED=true
     fi
   else
     git rebase
     SOURCES_CHANGED=true
   fi
   popd  
 }

# function check_git_changes {
#   pushd $1
#   if [ -z "$2" ]
#   then
#      local BRANCH="origin/master"
#   else
#      local BRANCH="remotes/origin/$2"
#   fi
#   echo "BRANCH= ${BRANCH}"
#   git checkout -b ${BRANCH}
#   git clean -fdx
#   local head=`git rev-parse ${BRANCH}`
#   git fetch
#   local origin=`git rev-parse ${BRANCH}`
#   if [ "$head" == "$origin" ]
#   then
#     echo "sources were not changed in $1, no point building a new build."
#     echo "git sha is: ${head}"
#     if [ "$FORCE" = true ]
#     then
#         echo "Warning force flag is on"
#         SOURCES_CHANGED=true
#     fi
#   else
#     git rebase
#     SOURCES_CHANGED=true
#   fi
#   popd
# }


check_git_changes ${SOURCES_DIR}/xap
check_git_changes ${SOURCES_DIR}/xap-jms
check_git_changes ${SOURCES_DIR}/xap-cassandra
check_git_changes ${SOURCES_DIR}/blobstore
check_git_changes ${SOURCES_DIR}/xap-blobstore-mapdb

if [ "${SOURCES_CHANGED}" = false ]
then 
  echo -1 > ${SOURCES_DIR}/build_status/stat
  exit 0
fi
  

if [ -z "${TGRID_BUILD_NUMBER}" ]
then 
   TGRID_BUILD_NUMBER=${BUILD_PREFIX}`./counter.sh`; export TGRID_BUILD_NUMBER
else
   TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER}
fi

if [ -z "${TGRID_S3_PUBLISH_FOLDER}" ] 
then
  TGRID_S3_PUBLISH_FOLDER="${TGRID_GS_PRODUCT_VERSION}-${TGRID_BUILD_NUMBER}-SNAPSHOT"; export TGRID_S3_PUBLISH_FOLDER
else
  TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER}
fi

(cd ${SOURCES_DIR}/xap && git pull)
(cd ${SOURCES_DIR}/blobstore && git pull)
(cd ${SOURCES_DIR}/xap-blobstore-mapdb && git pull)
(cd ${SOURCES_DIR}/xap-cassandra && git pull)
(cd ${SOURCES_DIR}/xap-jms && git pull)

export minimal="true"
export TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION}
#export TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER=${TGRID_GS_PRODUCT_VERSION}-${TGRID_BUILD_NUMBER}-SNAPSHOT}
export TGRID_MILESTONE=${TGRID_MILESTONE}
export TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE}
export TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE}
export TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS}
export TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS}
export TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION=${TGRID_GS_PRODUCT_VERSION} Sprint ${TGRID_MILESTONE}}
export TGRID_TARGET_JVM=${TGRID_TARGET_JVM}

mkdir -p ${SOURCES_DIR}/xap-jetty/jetty8/target
cp /opt/empty.zip ${SOURCES_DIR}/xap-jetty/jetty8/target/gs-openspaces-jetty-package.zip 

mkdir -p ${SOURCES_DIR}/xap-jetty/jetty9/target
cp /opt/empty.zip ${SOURCES_DIR}/xap-jetty/jetty9/target/gs-openspaces-jetty-9-package.zip


mkdir -p ${SOURCES_DIR}/openspaces-scala/openspaces-scala/target
cp /opt/empty.zip ${SOURCES_DIR}/openspaces-scala/openspaces-scala/target/gs-openspaces-scala.jar

mkdir -p ${SOURCES_DIR}/xap/core/tools/../../../openspaces-scala/openspaces-scala/target
cp /opt/empty.zip ${SOURCES_DIR}/xap/core/tools/../../../openspaces-scala/openspaces-scala/target/gs-openspaces-scala.jar



mkdir -p ${SOURCES_DIR}/mule/mule-latest/target
cp /opt/empty.zip ${SOURCES_DIR}/mule/mule-latest/target/mule-os-package.zip

mkdir -p ${SOURCES_DIR}/examples
cp /opt/empty_build.xml ${SOURCES_DIR}/examples/build.xml

mkdir -p ${SOURCES_DIR}/examples/release
cp /opt/empty.zip ${SOURCES_DIR}/examples/release/examples.zip

(cd ${SOURCES_DIR}/xap/tests && svn co svn://svn-srv/SVN/xap/trunk/quality/frameworks/TFRepository)

cd ${SOURCES_DIR}/xap 
SHA=`git rev-parse HEAD`; export SHA

echo "SHA=${SHA}"
echo "TGRID_BUILD_NUMBER=${TGRID_BUILD_NUMBER}"
echo "TGRID_GS_PRODUCT_VERSION=${TGRID_GS_PRODUCT_VERSION}"
echo "TGRID_S3_PUBLISH_FOLDER=${TGRID_S3_PUBLISH_FOLDER}"
echo "TGRID_MILESTONE=${TGRID_MILESTONE}"
echo "TGRID_SUITE_CUSTOM_EXCLUDE=${TGRID_SUITE_CUSTOM_EXCLUDE}"
echo "TGRID_SUITE_CUSTOM_INCLUDE=${TGRID_SUITE_CUSTOM_INCLUDE}"
echo "TGRID_SUITE_CUSTOM_JVMARGS=${TGRID_SUITE_CUSTOM_JVMARGS}"
echo "TGRID_SUITE_CUSTOM_SYSPROPS=${TGRID_SUITE_CUSTOM_SYSPROPS}"
echo "TGRID_QA_SUITE_VERSION=${TGRID_QA_SUITE_VERSION}"
echo "TGRID_TARGET_JVM=${TGRID_TARGET_JVM}"



(cd ${SOURCES_DIR}/xap/core/tools; ant -f quickbuild.xml minimal -Dmaven.repo.local="${SOURCES_DIR}/maven_repo_local" -Dnew.build.number="${TGRID_BUILD_NUMBER}" -Ds3.publish.folder="${TGRID_S3_PUBLISH_FOLDER}" -Dmilestone="${TGRID_MILESTONE}" -Dgs.product.version="${TGRID_GS_PRODUCT_VERSION}" -Dgit.sha="${SHA}" -Dtgrid.suite.custom.includepackage="${TGRID_SUITE_CUSTOM_INCLUDE}" -Dtgrid.suite.custom.excludepackage="${TGRID_SUITE_CUSTOM_EXCLUDE}" -Dtgrid.suite.custom.jvmargs="${TGRID_SUITE_CUSTOM_JVMARGS}" -Dtgrid.suite.custom.sysproperties="${TGRID_SUITE_CUSTOM_SYSPROPS}" -Dbuild.qa.suite.version="${TGRID_QA_SUITE_VERSION}" -Dtgrid.suite.target-jvm="${TGRID_TARGET_JVM}")

BUILD_STATUS=$?
if [ ${BUILD_STATUS} -ne 0 ]; then
  echo "Build failed!"
fi
mkdir -p -v ${SOURCES_DIR}/build_status
echo ${BUILD_STATUS} > ${SOURCES_DIR}/build_status/stat

echo "Clean temporary TFRepository"
rm -rf ${SOURCES_DIR}/xap/tests/TFRepository

echo "Restoring git repositories sources"
(cd ${SOURCES_DIR}/xap && git checkout .)
(cd ${SOURCES_DIR}/blobstore && git checkout .)
(cd ${SOURCES_DIR}/xap-blobstore-mapdb && git checkout .)
(cd ${SOURCES_DIR}/xap-cassandra && git checkout .)
(cd ${SOURCES_DIR}/xap-jms && git checkout .)


