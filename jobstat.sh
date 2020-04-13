#!/bin/bash

export cluster=somecluster

while true
do clear
  echo
  echo $cluster:
  echo
  echo gpu:
  /home/someguy/gridhpc/pestat -u someguy -p gpu -C|awk '{print $1"  "$3"  "$5"  "$6"  "$8"  "$9}' |tail -n +6|tail -90
  echo
  echo cpu:
  /home/someguy/gridhpc/pestat -u someguy -p main -C|awk '{print $1"  "$3"  "$5"  "$6"  "$8"  "$9}' |tail -n +6|tail -90
  echo
  sleep 5
done

