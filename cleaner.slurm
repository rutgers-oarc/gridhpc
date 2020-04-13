#!/bin/bash

#SBATCH -n 1
#SBATCH -J cleaner
#SBATCH -o out/out.%x.%N.%j
#SBATCH -e out/err.%x.%N.%j
#SBATCH -t 30:00
#SBATCH --requeue

echo hostname is $(hostname)
env |grep -i slurm

echo starting cleaner

CLEANDIR=$1
echo CLEANDIR is $CLEANDIR

if [ -d $CLEANDIR ]
# then mv $CLEANDIR $CLEANDIR-delete
 then rm -rf $CLEANDIR
  echo CLEANDIR removed
 else echo dir not found
fi
