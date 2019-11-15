#! /bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/ROBEX/elastix

subject_path=$1
echo
echo "Running Step 1 and 2 for subject: ${subject_path}"
bash epi_step1.sh ${subject_path} &
bash fieldmap_est2.sh ${subject_path} &
wait

echo "Running Step 3 and 4 for subject: ${subject_path}"
bash apply_fmap_mcflirt3.sh ${subject_path} &
bash anat_step4.sh ${subject_path} &
wait

echo
echo "Running Step 5 for subject: ${subject_path}"
bash Reg_Norm5.sh ${subject_path}

echo "Finished Successfully!"


