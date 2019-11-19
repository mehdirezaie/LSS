#!/bin/bash

eval "$(/home/mehdi/miniconda3/bin/conda shell.bash hook)"
conda activate py3p6



path2data=/B/Shared/Shadab/FA_LSS/
path2output=/home/mehdi/data/mocksys/


#
for mock_id in {10..18}
do
    echo $mock_id
    version=0.4
    
    # real space
    mpirun -np 4 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms ${path2data}FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                 --output ${path2output}pk_v0_${mock_id}_real_0_${version}.txt --real
   # redshift space
    mpirun -np 4 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                 --randoms ${path2data}FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                 --output ${path2output}mocksys/pk_v0_${mock_id}_red_0_${version}.txt

    # real space with subsampling
    mpirun -np 4 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms ${path2data}FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output ${path2output}pk_v0_${mock_id}_real_1_${version}.txt --real \
                                  --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits

    # redshift space with subsampling
    mpirun -np 4 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms ${path2data}FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output ${path2output}pk_v0_${mock_id}_red_1_${version}.txt \
                                  --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits
done

