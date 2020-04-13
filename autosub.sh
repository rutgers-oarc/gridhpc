#!/bin/bash

cputhresh=2
gputhresh=1
rundir=/home/someguy/gridhpc
cluster=somecluster
cpupart=main
gpupart=gpu
cpujob=rah,wcg
gpujob=fah
user=someguy

. /etc/profile.d/modules.sh 
ml -q singularity

cd $rundir
for cluster in $cluster;do
CPU_RUN=$(squeue -u $user -n $cpujob -p $cpupart -t running -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
GPU_RUN=$(squeue -u $user -n $gpujob -p $gpupart -t running -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
CPU_PEND=$(squeue -u $user -n $cpujob -p $cpupart -t pending -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
GPU_PEND=$(squeue -u $user -n $gpujob -p $gpupart -t pending -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
CLEANER=$(squeue -u $user -n cleaner -M $cluster|egrep -v "(NODES|CLUSTER)"|wc -l)
CPU_ALLOC=$(sinfo -t mix,alloc -p $cpupart -M $cluster -N|egrep -v "(NODES|CLUSTER)"|wc -l)
GPU_ALLOC=$(sinfo -t mix,alloc -p $gpupart -M $cluster -N|egrep -v "(NODES|CLUSTER)"|wc -l)
CPU_AVAIL=$(sinfo -t idle -p $cpupart -M $cluster -N|egrep -v "(NODES|CLUSTER)"|wc -l)
GPU_AVAIL=$(sinfo -t idle -p $gpupart -M $cluster -N|egrep -v "(NODES|CLUSTER)"|wc -l)
echo ---
echo date is $(date +"%F %r")
echo $(date +%s) seconds
echo $CPU_RUN running cpu jobs 
echo $GPU_RUN running gpu jobs 
echo $CPU_PEND pending cpu jobs 
echo $GPU_PEND pending gpu jobs 
echo $CLEANER cleaner jobs 
echo $CPU_ALLOC allocated cpu nodes
echo $GPU_ALLOC allocated gpu nodes
echo $CPU_AVAIL available cpu nodes
echo $GPU_AVAIL available gpu nodes
echo cputhresh is $cputhresh
echo gputhresh is $gputhresh
if [ "$GPU_PEND" -gt "0" ]
 then echo gpu no
 else if [ "$GPU_AVAIL" -lt "$gputhresh" ]
   then echo gpu no
   else echo gpu yes
   sbatch -M $cluster fah.slurm
  fi
fi
if [ "$CPU_PEND" -gt "0" ]
 then echo cpu no
 else if [ "$CPU_AVAIL" -lt "$cputhresh" ]
   then echo cpu no
   else echo cpu yes
   sbatch -M $cluster rah.slurm
   sbatch -M $cluster wcg.slurm
  fi
fi
done

echo done
echo
