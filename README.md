# gridhpc

Run volunteer computing grid jobs on traditional HPC clusters.

To generate singularity images, run something like the following:

ml singularity
sudo singularity build fold.simg fold sing

Change username, partitions, paths and so forth to customize the run scripts.

Autosub checks for pending jobs (no) and idle nodes (yes) and drips jobs into the queue.

Enable cluster preemption to run these jobs in a scavenger queue without impacting user jobs.
