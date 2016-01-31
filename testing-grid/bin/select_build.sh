#!/bin/bash

#echo "11839-6"
#exit 1

cd $1
newest=$(ls -t | grep 1 | head -1)
echo "${newest}"

