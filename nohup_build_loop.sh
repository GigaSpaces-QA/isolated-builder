#!/bin/bash
. env.sh
nohup ./build_loop.sh &> ${LOGS_DIR}/loop.log &
