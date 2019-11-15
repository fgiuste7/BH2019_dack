#! /bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/ROBEX/elastix

subject_path=$1
echo
echo "Running Step 1 and 2 for subject: ${subject_path}"
bash epi_step1.sh ${subject_path} &
bash anat_step2.sh ${subject_path} &

wait
echo
echo "Running Step 3 for subject: ${subject_path}"
bash anat_func_step3.sh ${subject_path}

echo "Finished Successfully!"


