#! /bin/bash

subject_path='/home/ubuntu/data/sub-141119'

bash epi_step1.sh ${subject_path} &
bash anat_step2.sh ${subject_path} &

wait
bash anat_func_step3.sh ${subject_path}


