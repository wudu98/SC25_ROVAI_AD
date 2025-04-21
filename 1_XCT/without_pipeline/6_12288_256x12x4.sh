#!/bin/sh -x
#PJM -L  "node=12288"                      # Assign node
#PJM -L  "rscgrp=large"                    # Specify resource group
#PJM -L  "elapse=02:00:00"                 # Elapsed time
#PJM --mpi "max-proc-per-node=1"           # Maximum number of MPI processes created per node
#PJM --llio sharedtmp-size=5Gi
#PJM --llio localtmp-size=70Gi
#PJM --llio cn-cache-size=20Gi
#PJM --llio sio-read-cache=on
#PJM --llio auto-readahead=on
#PJM -g  "ra000012"                        # group name
#PJM -x  PJM_LLIO_GFSCACHE=/vol0004        # volume names that job uses
#PJM -s                                    # Statistical information output

set -e

. /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load fujitsu-mpi@head%fj@4.11.1

output_slice_size=8192

sample_size=256
R_size=12
Z_size=1
Y_size=2
X_size=2
XYZ_size=`expr $Z_size \* $Y_size \* $X_size`
MPI_PARALLEL=`expr $sample_size \* $R_size \* $XYZ_size`       # Specify the number of MPI ranks

output_dir=/data/ra000012/spring8_image_recon_output/GC_12288_v1_${output_slice_size}_output_${sample_size}_${R_size}_${XYZ_size}/
if [[ -d $output_dir ]]; then
    rm -rf $output_dir
fi
mkdir -p $output_dir

export OMP_NUM_THREADS=48                                      # Specify the number of OMP threads
export OMPI_MCA_plm_ple_memory_allocation_policy=localalloc
export PLE_MPI_STD_EMPTYFILE=off
OPTION="--mca mpi_preconnect_mpi 0 --mca opal_mt_memcpy 1 --mca common_tofu_use_memory_pool 1"

tmp=`dirname $0`
PROJECT_ROOT=`cd $tmp/..; pwd`
cd ${PROJECT_ROOT}

EXEFILE=${PROJECT_ROOT}/build/v1_MPI_FBP_main

llio_transfer ${EXEFILE}

for ((i=0; i<$sample_size; i++)); do
    I=$(printf "%03d\n" "${i}")
    conf_file=${PJM_SHAREDTMP}/sample_${I}.conf
    > $conf_file
done

sample_rank=0

while read -r line; do

    if [[ $line =~ ^#.* ]] || [[ -z "$line" ]]; then
        continue
    fi

    read -r id dir_name scan_count nv nu np offset_CT RC dark_size pre_flat_size post_flat_size <<< "$line"

    ID1=$(printf "%03d\n" "${id}")
    scan_count=12

    for ((i=0; i<$scan_count; i++)); do
        ID2=$(printf "%03d\n" "${i}")
        input_path=/2ndfs/ra000012/image_recon_data/distributed_input/${R_size}_chunks/No_${ID1}/${ID2}/
        output_path=${output_dir}/No_${ID1}/${ID2}/
        cor_conf_file=/2ndfs/ra000012/image_recon_data/distributed_input/cor/No_${ID1}/cor.conf

        if [ -e "$cor_conf_file" ]; then
            RC=$(sed -n "$(($i + 1))p" "$cor_conf_file")
        fi

        ID3=$(printf "%03d\n" "${sample_rank}")
        conf_file=${PJM_SHAREDTMP}/sample_${ID3}.conf
        echo $input_path $output_path $nv $nu $np $offset_CT $RC >> $conf_file
        sample_rank=$((($sample_rank + 1) % $sample_size))
    done

done < ${PROJECT_ROOT}/config.conf

tm0=$(date +%s)
time mpiexec -n ${MPI_PARALLEL} ${OPTION} $EXEFILE ${PJM_LOCALTMP} ${PJM_SHAREDTMP} $sample_size $R_size $Z_size $Y_size $X_size $output_slice_size
tm1=$(date +%s)

echo "Elapsed Time : $((($tm1-$tm0))) s" 

llio_transfer --purge ${EXEFILE}
