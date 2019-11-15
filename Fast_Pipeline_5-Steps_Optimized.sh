#! /bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/ROBEX/elastix

subject_path=$1
echo
echo "Running Step 1 and 2 for subject: ${subject_path}"
bash step1.sh ${subject_path} &
bash step2.sh ${subject_path} &
wait

echo "Running Step 3 and 4 for subject: ${subject_path}"
bash step3.sh ${subject_path} &
bash step4.sh ${subject_path} &
wait

echo
echo "Running Step 5 for subject: ${subject_path}"
bash step5.sh ${subject_path}

echo "Finished Successfully!"


