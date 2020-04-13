#!/bin/bash

export cluster=somecluster

while true
do for part in gpu main
  do clear
    echo $cluster:
    echo
    echo $part:
    echo
    /home/someguy/gridhpc/pestat -u someguy -p $part -C|awk '{print $1"  "$3"  "$5"  "$6"  "$8"  "$9}' |tail -n +6|tail -90
    sleep 5
  done
done

