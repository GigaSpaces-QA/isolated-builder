#!/bin/bash

INTERVAL=60
while true; do    
    COUNT=`cat counter.tmp`
    #synchronize the counter to the counter inside the docker container
    CURRENT_BUILD=$(expr $COUNT + 1)
    echo "Running build ${CURRENT_BUILD}"
    mkdir -p -v logs/${CURRENT_BUILD}
    build_logdir="logs/${CURRENT_BUILD}"
    echo "-- redirecting output to ${build_logdir} --"
    sleep 10
    echo "-- build logs at ${build_logdir}/build.log --"
    ./run_build_process.sh &> ${build_logdir}/build.log    
    echo "waiting ${INTERVAL} seconds to trigger next build"
    sleep ${INTERVAL}
done


