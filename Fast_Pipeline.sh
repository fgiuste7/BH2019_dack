#! /bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/ROBEX/elastix

subject_path=$1

bash epi_step1.sh ${subject_path} &
bash anat_step2.sh ${subject_path} &

wait
bash anat_func_step3.sh ${subject_path}


