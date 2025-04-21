#!/bin/bash
#SBATCH -A xxxxx
#SBATCH -o sap_s8d_ddp.o%J
#SBATCH -t 12:00:00
#SBATCH -N 32
#SBATCH -p batch

export MIOPEN_DISABLE_CACHE=1 
export MIOPEN_CUSTOM_CACHE_DIR='pwd' 
export HOME="/tmp/srun"

source export_ddp_envs.sh

module load PrgEnv-gnu/8.5.0
module load gcc/12.2.0
module load rocm/6.2.0

# exec
srun -N 32 -n 256 --ntasks-per-node 8 python ./train/sap_s8d_ddp.py \
        --data_dir=/lustre/orion/nro108/world-shared/xxx/Riken_XCT_Simulated_Data/8192x8192_2d_Simulations/Noise_0.05_Blur_2_sparsity_2_NumAng_3600 \
        --epoch=100 \
        --resolution=8192 \
        --fixed_length=8192 \
        --patch_size=8 \
        --pretrain=sam-b \
        --batch_size=1 \
        --savefile=./sap_s8d_n32-deq2
# 8281