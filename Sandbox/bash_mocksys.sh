#!/bin/bash

eval "$(/home/mehdi/miniconda3/bin/conda shell.bash hook)"
conda activate py3p6



for mock_id in {10..18}
do
    echo $mock_id
    version=0.3
    # real space
    mpirun -np 8 python run_pk.py --data /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output /home/mehdi/data/mocksys/pk_v0_${mock_id}_real_0_${version}.txt --real
    # redshift space
    mpirun -np 8 python run_pk.py --data /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output /home/mehdi/data/mocksys/pk_v0_${mock_id}_red_0_${version}.txt

    # real space with subsampling
    mpirun -np 8 python run_pk.py --data /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output /home/mehdi/data/mocksys/pk_v0_${mock_id}_real_1_${version}.txt --real \
                                  --mask /B/Shared/Shadab/FA_LSS/EZmock_desi_v0.0_${mock_id}/bool_index.fits

    # redshift space with subsampling
    mpirun -np 8 python run_pk.py --data /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms /B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0*.fits \
                                  --output /home/mehdi/data/mocksys/pk_v0_${mock_id}_red_1_${version}.txt \
                                  --mask /B/Shared/Shadab/FA_LSS/EZmock_desi_v0.0_${mock_id}/bool_index.fits
done

