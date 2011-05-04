#!/bin/sh
#agricola.sh
#Torque script to run Matlab program

#Torque directives
#PBS -N simPossGLM
#PBS -W group_list=<GROUP>
#PBS -l nodes=1,walltime=00:10:00,mem=1000mb
#PBS -M kss2137@columbia.edu
#PBS -m abe
#PBS -V

#set output and error directories (SSCC example here)
#PBS -o localhost:~/hpc_tmp/example_dir/
#PBS -e localhost:~/hpc_tmp/example_dir/

#define parameter lambda
LAMBDA=10

#Command to execute Matlab code
matlab -nosplash -nodisplay -nodesktop -r "simPoissGLM($LAMBDA)" > matoutfile

#Command below is to execute Matlab code for Job Array (Example 4) so that each part writes own output
#matlab -nosplash -nodisplay -nodesktop -r "simPoissGLM($LAMBDA)" > matoutfile.$PBS_ARRAYID