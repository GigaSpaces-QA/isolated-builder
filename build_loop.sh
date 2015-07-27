#!/bin/bash
. env.sh
INTERVAL=60
while true; do    
    branch_list=`cat ${BRANCH_LIST_FILE}`
    IFS=',' read -a branch_array <<< "${branch_list}"
    if [ -z "${branch_array}" ]
    then
      echo "please enter at least one branch in branch_list.txt"
      exit 1  
    fi
    for branch in "${branch_array[@]}"
    do
      echo "BRANCH is: ${branch}"
      export GIT_BRANCH=${branch}    
      COUNT=`cat ${COUNTER_FILE}`
      #synchronize the counter to the counter inside the docker container
      CURRENT_BUILD=$(expr $COUNT + 1)
      echo "Running build ${CURRENT_BUILD}"
      mkdir -p -v ${LOGS_DIR}/${CURRENT_BUILD}
      build_logdir="${LOGS_DIR}/${CURRENT_BUILD}"
      echo "-- redirecting output to ${build_logdir} --"
      sleep 10
      echo "-- build logs at ${build_logdir}/build.log --"   
      ./run_build_process.sh &> ${build_logdir}/build.log    
      echo "waiting ${INTERVAL} seconds to trigger next build"
      sleep ${INTERVAL}
    done
done


