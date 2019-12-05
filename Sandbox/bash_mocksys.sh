#!/bin/bash

#
# activate my env which has nbodykit 
# and fitsio change (https://github.com/esheldon/fitsio/pull/278) is in effect
# depending on the version of fitsio on nersc, the code might fail
# 
eval "$(/home/mehdi/miniconda3/bin/conda shell.bash hook)"
conda activate py3p6


# `path2data` is the path to mocks and randoms
# `path2output` is the path to which the pks will be written
# `path2randoms` is a sequence of paths to randoms -- 00 01 02
#  we notice a lot of overhead when using all 6 randoms

path2data=/B/Shared/Shadab/FA_LSS/
path2output=/home/mehdi/data/mocksys/
path2randoms=/B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0[0,1,2].fits



# set the env variable for numexpr
export NUMEXPR_MAX_THREADS=8



#
# loop over mockid = 2 - 100 * mockid=1 is corrputed
# one of the arguments to run_pk is zlim which is 0.7 1.5 by default
# eg. --zlim 0.7 1.5

for mock_id in {2..100}
do
    echo $mock_id
    version=0.5
    
    # real space
    mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                 --randoms $path2randoms \
                                 --output ${path2output}pk_v0_${mock_id}_real_0_${version}.txt --real
    # redshift space
    mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                   --randoms $path2randoms \
                                 --output ${path2output}pk_v0_${mock_id}_red_0_${version}.txt

    # real space with subsampling
    mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                 --randoms $path2randoms \
                                  --output ${path2output}pk_v0_${mock_id}_real_1_${version}.txt --real \
                                  --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits

    # redshift space with subsampling
    mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
                                  --randoms $path2randoms \
                                 --output ${path2output}pk_v0_${mock_id}_red_1_${version}.txt \
                                  --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits
done
