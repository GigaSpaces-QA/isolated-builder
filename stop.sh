#!/bin/bash

docker rm -f xap

PID=`ps -eaf | grep build_loop.sh | grep -v grep | awk '{print $2}'`

echo "current pid of builder is: ${PID}"
if [[ "" !=  "$PID" ]]; then
  echo "killing builder with pid: ${PID}"
  kill -9 ${PID}
fi
