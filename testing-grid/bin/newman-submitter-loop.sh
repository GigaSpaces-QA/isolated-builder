#!/bin/bash
while true; do
        source submitter-env.sh

        FORCE_RUN=${NEWMAN_FORCE_RUN=false};
        FORCED_BRANCH=${NEWMAN_FORCE_BRANCH=master}
        FORCED_TAGS=${NEWMAN_FORCE_TAGS=""}

        # force run - running nightly suites
        if ${FORCE_RUN};
        then
                echo "running in FORCE_RUN mode, e.g nightly suite, date is `date`"
                export NEWMAN_SUITES="${NEWMAN_SUITES},${NEWMAN_NIGHTLY_SUITES}"
                export NEWMAN_BUILD_BRANCH=${FORCED_BRANCH}
                export NEWMAN_BUILD_TAGS=${FORCED_TAGS}

                echo "NEWMAN_SUITES=${NEWMAN_SUITES}"
                echo "NEWMAN_BUILD_BRANCH=${NEWMAN_BUILD_BRANCH}"
                echo "NEWMAN_BUILD_TAGS=${NEWMAN_BUILD_TAGS}"

                java -jar newman-submitter-1.0.jar
                echo "finished force run ..."
        fi
        # run force run only once
        export NEWMAN_FORCE_RUN=false

        # take branches from file
        branch_list=`cat ${BRANCH_FILE_PATH}`
        IFS=',' read -a branch_array <<< "${branch_list}"
        echo "starting loop over branches ..."


        # loop over all branches
        for branch in "${branch_array[@]}"
        do
                # current hour
                HOURS=$(date +%H)

                # check if nightly or daily mode - every branch
                if [ $HOURS -ge 19 -a $HOURS -le 22 ];
                then
                        echo "running in nightly mode, will trigger new jobs even if no changes where made, date is `date`"
                        export NEWMAN_SUITES="${NEWMAN_SUITES},${NEWMAN_NIGHTLY_SUITES}"
                        export NEWMAN_MODE="NIGHTLY"
                        export NEWMAN_BUILD_TAGS="DOTNET"
                else
                        echo "running in daily mode, will trigger new jobs only if changes in build were made, date is `date`"
                        export NEWMAN_MODE="DAILY"
                        export NEWMAN_BUILD_TAGS=""
                fi

                export NEWMAN_BUILD_BRANCH=${branch}

                echo "NEWMAN_SUITES=${NEWMAN_SUITES}"
                echo "NEWMAN_BUILD_BRANCH=${NEWMAN_BUILD_BRANCH}"
                echo "NEWMAN_BUILD_TAGS=${NEWMAN_BUILD_TAGS}"
                echo "NEWMAN_MODE=${NEWMAN_MODE}"

                #checking future job
                java -jar newman-submitter-1.0.jar
                HAS_FUTURE_JOBS=$?
                echo "HAS_FUTURE_JOBS=${HAS_FUTURE_JOBS}"
                while [ $HAS_FUTURE_JOBS -ne 0 ]; do
                        echo "Has future jobs, trying again..."
                        java -jar newman-submitter-1.0.jar
                        HAS_FUTURE_JOBS=$?
                        sleep 120
                done
                echo "finish submitter work!"

        done
done
