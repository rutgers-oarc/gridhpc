#!/bin/sh

#SBATCH -N 1
#SBATCH --exclusive 
#SBATCH -J fah
#SBATCH -o out/out.%x.%N.%j
#SBATCH -e out/err.%x.%N.%j
#SBATCH -t 1-0
#SBATCH -p gpu
#SBATCH -q gpu
#SBATCH -A gpu
#SBATCH --no-requeue
#SBATCH --signal=TERM

echo Starting job $SLURM_JOB_NAME on `hostname` at `date +%F" "%T`
echo

. /etc/profile.d/modules.sh
ml -q cuda singularity

export RUNTIME=600
export CLEANPART=$SLURM_JOB_PARTITION
export CLEANQOS=$SLURM_JOB_QOS
export CLEANACCT=$SLURM_JOB_ACCOUNT
export SINGULARITY_BINDPATH="/scratch"
export IMAGE=/home/someuser/gridhpc/fold.simg
export RUNBASE=/home/someuser/gridhpc/base.fah
export RUNDIR=/scratch/someuser/gridhpc/$SLURM_JOB_NAME.$SLURM_CLUSTER_NAME.$SLURM_JOB_ID
export SINGCMD="singularity exec --nv -B /etc/OpenCL/vendors $IMAGE FAHClient --user=someuser --team=<teamid> --smp=true --gpu=true --chdir=$RUNDIR --exit-when-done --max-units 1 --max-queue 1 --checkpoint 1"
export SINGEXIT="singularity exec $IMAGE FAHClient --chdir=$RUNDIR --send-finish"

#echo RUNDIR is $RUNDIR
#echo SINGCMD is $SINGCMD
#echo SINGEXIT is $SINGEXIT

# slurm environment
env |grep -i slurm
echo

# queue up cleaner
echo Queueing cleaner `date +%T`
sbatch --dependency=afternotok:$SLURM_JOB_ID --kill-on-invalid-dep=yes -M $SLURM_CLUSTER_NAME -p $CLEANPART -q $CLEANQOS -A $CLEANACCT cleaner.slurm $RUNDIR

# create run dir
echo Creating rundir `date +%T`
mkdir -p $RUNDIR
# for a custom config.xml
#rsync -a --delete $RUNBASE/ $RUNDIR/

# start client
echo Starting client `date +%T`
srun $SINGCMD &
sleep 120

export STARTTIME=`date +%s`
echo starttime is $STARTTIME

# wait runtime
echo sleeping runtime
sleep $RUNTIME

# no more tasks
echo sending finish
srun $SINGEXIT

# wait for client exit
wait

echo client exit +`date +%T`
echo "Exit code: " $? "  " `date +%T`

echo Removing rundir `date +%T`
rm -rf $RUNDIR

sacct --format NTasks,MaxRSS,Elapsed,AveRSS,AveCPU -j $SLURM_JOBID

echo Done at +$(($((`date +%s`-$STARTTIME))/60)) minutes

exit
