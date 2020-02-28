#!/bin/bash

#
# activate my env which has nbodykit 
# and fitsio change (https://github.com/esheldon/fitsio/pull/278) is in effect
# depending on the version of fitsio on nersc, the code might fail
# 
eval "$(/home/mehdi/miniconda3/bin/conda shell.bash hook)"
conda activate py3p6



# codes
run_prepare=${HOME}/github/LSSutils/scripts/analysis/projectDesiMocks.py
ablation=${HOME}/github/LSSutils/scripts/analysis/ablation_tf_old.py
multfit=${HOME}/github/LSSutils/scripts/analysis/mult_fit.py
nnfit=${HOME}/github/LSSutils/scripts/analysis/nn_fit_tf_old.py
docl=${HOME}/github/LSSutils/scripts/analysis/run_pipeline.py
elnet=${HOME}/github/LSSutils/scripts/analysis/elnet_fit.py
pk=${HOME}/github/LSSutils/scripts/analysis/run_pk.py

# `path2data` is the path to mocks and randoms
# `path2output` is the path to which the pks will be written
# `path2randoms` is a sequence of paths to randoms -- 00 01 02
#  we notice a lot of overhead when using all 6 randoms

path2data=/B/Shared/Shadab/FA_LSS/
path2output=/B/Shared/mehdi/mocksys/
path2randoms=/B/Shared/Shadab/FA_LSS/FA_EZmock_desi_ELG_v0_rand_0[0,1,2].fits



# set the env variable for numexpr
export NUMEXPR_MAX_THREADS=8



#
# loop over mockid = 2 - 100 * mockid=1 is corrputed


#
#---- Power Spectrum
# one of the arguments to run_pk is zlim which is 0.7 1.5 by default
# eg. --zlim 0.7 1.5

#for mock_id in {2..100}
# do
#     echo $mock_id
#     version=0.6
    
#     # real space
#     mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
#                                  --randoms $path2randoms \
#                                  --output ${path2output}pk_v0_${mock_id}_real_0_${version}.txt --real
#     # redshift space
#     mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
#                                    --randoms $path2randoms \
#                                  --output ${path2output}pk_v0_${mock_id}_red_0_${version}.txt

#     # real space with subsampling
#     mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
#                                  --randoms $path2randoms \
#                                   --output ${path2output}pk_v0_${mock_id}_real_1_${version}.txt --real \
#                                   --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits

#     # redshift space with subsampling
#     mpirun -np 8 python run_pk.py --data ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits \
#                                   --randoms $path2randoms \
#                                  --output ${path2output}pk_v0_${mock_id}_red_1_${version}.txt \
#                                   --mask ${path2data}EZmock_desi_v0.0_${mock_id}/bool_index.fits
# done


#---- Regression

# prepare for regression
for mock_id in {2..100}
do
    echo $mock_id
    #du -h ${path2data}FA_EZmock_desi_ELG_v0_${mock_id}.fits
    python $run_prepare $mock_id
done
#



# perform the regression
nside=256
axfit0='2 3 4'
axfit1='0 1 2 3 4 5 6 7 8 9 10 11 12'

for mock_id in {2..10}
do
    for zcut in all low high 
    do 
        echo $mock_id
        output_dir=/B/Shared/mehdi/mocksys/regression
        ngal_features_5fold=${output_dir}/ngal_features_${mock_id}_${zcut}_${nside}.5r.npy

        # define output dirs
        oudir_ab=${output_dir}/results/${mock_id}/${zcut}_${nside}/ablation/
        oudir_reg=${output_dir}/results/${mock_id}/${zcut}_${nside}/regression/            

        # define output names
        log_ablation=desi_mock.log
        nn1=nn_ablation
        nn2=nn_plain           
        nn3=nn_known
        mult1=mult_plain

        du -h ${ngal_features_5fold}
        echo $oudir_ab
        echo $oudir_reg

        # ablation
        for fold in 0 1 2 3 4
        do
           echo "feature selection on " $fold ${mock_id}_${zcut}
           mpirun -np 13 python $ablation --data $ngal_features_5fold \
                         --output $oudir_ab --log $log_ablation \
                         --rank $fold --axfit $axfit1
        done      

        echo 'regression on ' $fold ${mock_id}_${zcut}
        # regression with ablation
         mpirun -np 5 python $nnfit --input $ngal_features_5fold \
                            --output ${oudir_reg}${nn1}/ \
                            --ablog ${oudir_ab}${log_ablation} --nside $nside

         # regression with all maps
         mpirun -np 5 python $nnfit --input $ngal_features_5fold \
                           --output ${oudir_reg}${nn2}/ --nside $nside --axfit $axfit1 

         # regression with known maps
         mpirun -np 5 python $nnfit --input $ngal_features_5fold \
                           --output ${oudir_reg}${nn3}/ --nside $nside --axfit $axfit0 

          # regression with all maps with standard approach
         python $multfit --input $ngal_features_5fold \
                        --output ${oudir_reg}${mult1}/ \
                        --split --nside $nside --axfit $axfit1
    done    
done
