#!/bin/bash

user=<someuser>
cluster=<somecluster>
rundir=/home/<someuser>/gridhpc

function qcheck {
  if [ $# -ne 4 ]
    then echo "Wrong number of arguments"
    exit 1
  fi
  jobname=$1
  partition=$2
  qos=$3
  idlethresh=$4
  PENDINGJOBS=$(squeue -u $user -n $jobname -p $partition -t pending -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
  IDLENODES=$(sinfo -t idle -p $partition -M $cluster -N|egrep -v "(NODES|CLUSTER)"|wc -l)
  echo ---
  echo checking partition $partition:
  echo date is $(date +"%F %r")
  echo $PENDINGJOBS pending, $IDLENODES idle
  if [ "$PENDINGJOBS" -gt "0" ]
    then echo no - pend
    else if [ "$IDLENODES" -le "$idlethresh" ]
      then echo no - idle
      else echo yes
      sbatch -M $cluster -p $partition -q $qos ${jobname}.slurm
    fi
  fi
}

cd $rundir

qcheck fah gpu gpu 5
qcheck boinc main normal 20

echo done

