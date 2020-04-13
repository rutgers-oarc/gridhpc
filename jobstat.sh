#!/bin/bash

export cluster=somecluster

while true
do clear
  echo
  echo $cluster:
  echo
  /home/someguy/gridhpc/pestat -u someguy -C|awk '{print $1"  "$3"  "$5"  "$6"  "$8"  "$9}' |tail -n +6|tail -90;sleep 5
  echo
done

