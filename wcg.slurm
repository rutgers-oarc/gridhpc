#!/bin/bash

#SBATCH -N 1
#SBATCH --exclusive
#SBATCH -J wcg
#SBATCH -o out/out.%x.%N.%j
#SBATCH -e out/err.%x.%N.%j
#SBATCH -t 1-0
#SBATCH -p main
#SBATCH -A main
#SBATCH -q main
#SBATCH --no-requeue

echo Starting job $SLURM_JOB_NAME on `hostname` at `date +%F" "%T`
echo

. /etc/profile.d/modules.sh
ml -q singularity

# work runtime
export RUNTIME=600
echo runtime is $RUNTIME

export CLEANPART=$SLURM_JOB_PARTITION
export CLEANQOS=$SLURM_JOB_QOS
export CLEANACCT=$SLURM_JOB_ACCOUNT
export SINGULARITY_BINDPATH="/scratch"
export IMAGE=/home/someuser/gridhpc/boinc.simg
export RUNBASE=/home/someuser/gridhpc/base.boinc
export RUNDIR=/scratch/someuser/gridhpc/$SLURM_CLUSTER_NAME.$SLURM_JOB_NAME.$SLURMD_NODENAME.$SLURM_JOB_ID
export BOINC=/bin/boinc
export BOINCCMD=/bin/boinccmd
export SINGCMD="singularity exec $IMAGE"
export PROJECT="www.worldcommunitygrid.org"
export PROJECTKEY="<somekey>"

echo RUNDIR is $RUNDIR
echo SINGCMD is $SINGCMD

# slurm environment
env |grep -i slurm
echo

# queue up cleaner
echo Queueing cleaner `date +%T`
sbatch --dependency=afternotok:$SLURM_JOB_ID --kill-on-invalid-dep=yes -M $SLURM_CLUSTER_NAME -p $CLEANPART -q $CLEANQOS -A $CLEANACCT cleaner.slurm $RUNDIR

# create run dir
echo Copying rundir `date +%T`
mkdir -p $RUNDIR
rsync -a --delete $RUNBASE/ $RUNDIR/
cd $RUNDIR
echo pwd is `pwd` `date +%T`

# start client
echo Starting client `date +%T`
srun $SINGCMD $BOINC --dir $RUNDIR &
sleep 120

export STARTTIME=`date +%s`
echo starttime is $STARTTIME

# run
echo Attaching to project `date +%T`
echo pwd is `pwd` `date +%T`
srun $SINGCMD $BOINCCMD --project_attach $PROJECT $PROJECTKEY &

# wait
echo Waiting runtime `date +%T`
sleep $RUNTIME

# no more tasks
echo No more work +$(($((`date +%s`-$STARTTIME))/60)) minutes
srun $SINGCMD $BOINCCMD --project $PROJECT nomorework

# wait for client exit
wait

echo client exit +`date +%T`

echo "Exit code: " $? "  " `date +%T`

echo Removing rundir `date +%T`
rm -rf $RUNDIR

sleep 3
sacct --format NTasks,MaxRSS,Elapsed,AveRSS,AveCPU -j $SLURM_JOBID
sleep 3

echo  Done at +$(($((`date +%s`-$STARTTIME))/60)) minutes

exit
