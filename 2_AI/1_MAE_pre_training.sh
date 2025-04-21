#!/bin/bash
#SBATCH -A lrn075
#SBATCH -J mae_simple
#SBATCH --nodes=256
#SBATCH --gres=gpu:8
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH -t 12:00:00
#SBATCH -p batch
#SBATCH -o mae_simple-n256-%j.out
#SBATCH -e mae_simple-n256-%j.out

[ -z $JOBID ] && JOBID=$SLURM_JOB_ID
[ -z $JOBSIZE ] && JOBSIZE=$SLURM_JOB_NUM_NODES

#ulimit -n 65536

# #source miniconda
# source /lustre/orion/proj-shared/stf006/irl1/conda/bin/activate
source deactivate
# #conda activate /lustre/orion/bif146/world-shared/irl1/flash-attention-torch25
# #Stable conda environment
conda activate /lustre/orion/bif146/world-shared/irl1/torch-stable

module load PrgEnv-gnu
module load gcc/12.2.0

#module load rocm/6.2.0 libtool
#export LD_LIBRARY_PATH=/lustre/orion/world-shared/stf218/junqi/climax/rccl-plugin-rocm6/lib/:/opt/rocm-6.2.0/lib:$LD_LIBRARY_PATH
#Stable conda environment
module load rocm/5.7.0 libtool
export LD_LIBRARY_PATH=/lustre/orion/world-shared/stf218/atsaris/env_test_march/rccl/build:/lustre/orion/world-shared/stf218/atsaris/env_test_march/rccl-plugin-rocm570/lib/:/opt/cray/libfabric/1.15.2.0/lib64/:/opt/rocm-5.7.0/lib:$LD_LIBRARY_PATH

export MIOPEN_DISABLE_CACHE=1
export NCCL_PROTO=Simple
export MIOPEN_USER_DB_PATH=/tmp/$JOBID
mkdir -p $MIOPEN_USER_DB_PATH


export OMP_NUM_THREADS=7
export PYTHONPATH=$PWD:$PYTHONPATH

time srun -n $((SLURM_JOB_NUM_NODES*8)) \
python ./src/train_masked_simple.py ./configs/s8d_2d/mae/multidata-n256.yaml