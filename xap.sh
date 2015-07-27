#!/bin/bash

FORCE=${FORCE=false}
SOURCES_CHANGED=false
SOURCES_DIR='/sources'
BUILD_PREFIX='12800-'
GIT_BRANCH=${GIT_BRANCH=''}

mkdir -p -v ${SOURCES_DIR}/build_status

   function check_git_changes {
    pushd $1
    if [ -z "$2" ] || [ "$2" == "master" ]
    then
       local BRANCH="origin/master"
       git checkout master
    else
       local BRANCH="remotes/origin/$2"
       git show-ref --verify --quiet refs/heads/$2
       if [ $? -eq 0 ]
       then
         echo "branch $2 exists locally executing git checkout $2"
         git checkout $2
       else
         echo "branch $2 does not exists locally executing git checkout -t -f ${BRANCH}"
         git checkout -t -f ${BRANCH}
       fi
       git branch --set-upstream $2 ${BRANCH}
    fi
    echo "BRANCH= ${BRANCH}"
    git clean -fdx
    git checkout .
    local head=`git rev-parse HEAD`
    git fetch
    local origin=`git rev-parse ${BRANCH}`
    if [ "$head" == "$origin" ]
    then
      echo "sources were not changed in $1."
      echo "git sha is: ${head}"
      if [ "$FORCE" = true ]
      then
          SOURCES_CHANGED=true
      fi
    else
      git rebase
      SOURCES_CHANGED=true
    fi
    popd
  }

echo "GIT_BRANCH=${GIT_BRANCH}"

if [ "$FORCE" = true ]
then  
  echo "Warning force flag is on - build will be created even though no changes were made in github"
fi

check_git_changes ${SOURCES_DIR}/xap ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-jms ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-cassandra ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/blobstore ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-blobstore-mapdb ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-jetty ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-apm-introscope ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/xap-rest ${GIT_BRANCH}
check_git_changes ${SOURCES_DIR}/rest-data ${GIT_BRANCH}

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

rm -rf ${SOURCES_DIR}/examples

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

mkdir -p ${SOURCES_DIR}/examples/release

#build examples
pushd ${SOURCES_DIR}/examples
mkdir examples
git clone git@github.com:Gigaspaces/xap-example-data.git
git clone git@github.com:Gigaspaces/xap-example-tutorials.git 
git clone git@github.com:Gigaspaces/xap-example-web.git
git clone git@github.com:Gigaspaces/xap-example-helloworld.git
cp -f xap-example-data/build.xml .
cp -R xap-example-data/examples/* examples/
cp -R xap-example-tutorials/examples/* examples/
cp -R xap-example-web/examples/* examples/
cp -R xap-example-helloworld/examples/* examples/
popd

(cd ${SOURCES_DIR}/xap/tests && svn co svn://192.168.9.34/SVN/xap/trunk/quality/frameworks/TFRepository)
(cd ${SOURCES_DIR} && svn co svn://192.168.9.34/SVN/xap/trunk/quality/frameworks/SGTest)

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

pushd ${SOURCES_DIR}
git clone https://github.com/kobikis/sgtest-test-generator.git
cd sgtest-test-generator
mvn install -Dmaven.repo.local=${SOURCES_DIR}/maven_repo_local
cd ..
rm -rf ${SOURCES_DIR}/sgtest-test-generator
pushd

pushd ${SOURCES_DIR}/SGTest
mvn package -Dmaven.repo.local=${SOURCES_DIR}/maven_repo_local
mkdir -p ${SOURCES_DIR}/sgtest-jar
cp -f target/SGTest*.jar ${SOURCES_DIR}/sgtest-jar
popd

echo "Clean temporary TFRepository & SGTest"
rm -rf ${SOURCES_DIR}/xap/tests/TFRepository
rm -rf ${SOURCES_DIR}/SGTest

echo "Publishing newman artifacts"
pushd ${SOURCES_DIR}/xap/newman-artifacts
mvn package -Dmaven.repo.local=${SOURCES_DIR}/maven_repo_local
mkdir -p ${SOURCES_DIR}/newman-artifacts
cp -f target/newman-artifacts.zip ${SOURCES_DIR}/newman-artifacts
popd

echo "Writing xap metadata"
mkdir -p ${SOURCES_DIR}/metadata
echo [ \"xap\":\"${SHA}\" ] > ${SOURCES_DIR}/metadata/metadata.txt

#echo "Restoring git repositories sources"
#(cd ${SOURCES_DIR}/xap && git checkout .)
#(cd ${SOURCES_DIR}/blobstore && git checkout .)
#(cd ${SOURCES_DIR}/xap-blobstore-mapdb && git checkout .)
#(cd ${SOURCES_DIR}/xap-cassandra && git checkout .)
#(cd ${SOURCES_DIR}/xap-jms && git checkout .)
#(cd ${SOURCES_DIR}/xap-jetty && git checkout .)
#(cd ${SOURCES_DIR}/xap-apm-introscope && git checkout .)
#(cd ${SOURCES_DIR}/xap-rest && git checkout .)
#(cd ${SOURCES_DIR}/rest-data && git checkout .)

