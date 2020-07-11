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

export CLEANPART=$SLURM_JOB_PARTITION
export CLEANQOS=$SLURM_JOB_QOS
export CLEANACCT=$SLURM_JOB_ACCOUNT
export SINGULARITY_BINDPATH="/scratch"
export IMAGE=/home/someuser/gridhpc/fah.simg
export RUNBASE=/home/someuser/gridhpc/fah.base
export RUNDIR=/scratch/someuser/gridhpc/$SLURM_JOB_NAME.$SLURM_CLUSTER_NAME.$SLURM_JOB_ID
export SINGCMD="singularity exec --nv -B /etc/OpenCL/vendors $IMAGE FAHClient --user=<someuser> --team=<teamid> --smp=true --gpu=true --exit-when-done --max-units=1 --max-queue=1 --gui-enabled=false --chdir=$RUNDIR"

# slurm environment
env |grep -i slurm
echo

# queue up cleaner
echo Queueing cleaner `date +%T`
sbatch --dependency=afternotok:$SLURM_JOB_ID --kill-on-invalid-dep=yes -M $SLURM_CLUSTER_NAME -p $CLEANPART -q $CLEANQOS -A $CLEANACCT cleaner.slurm $RUNDIR

# create run dir
echo Creating rundir `date +%T`
mkdir -p $RUNDIR
# for single gpu uncomment
#rsync -a --delete $RUNBASE/ $RUNDIR/

# start client
echo Starting client `date +%T`
srun $SINGCMD &
sleep 120

export STARTTIME=`date +%s`
echo starttime is $STARTTIME

# wait for client exit
wait

echo client exit +`date +%T`
echo "Exit code: " $? "  " `date +%T`

echo Removing rundir `date +%T`
rm -rf $RUNDIR

sacct --format NTasks,MaxRSS,Elapsed,AveRSS,AveCPU -j $SLURM_JOBID

echo Done at +$(($((`date +%s`-$STARTTIME))/60)) minutes

exit
