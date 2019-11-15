#! /bin/bash

# To run: 
# bash runAll.sh

base_dir='/home/ubuntu/data/'
cd ${base_dir}

subjects=`ls -d ${base_dir}/sub-*`

for subj in ${subjects}; do
	echo "Subject: ${subj}"
	bash ./Fast_Pipeline_5-Steps_Optimized.sh ${subj} &
done

echo 'WAITING...'
wait
echo 'Pipeline DONE'
#echo "Saving derivatives/ to s3 bucket"
#aws s3 cp derivatives/ "s3://d4ck/" --recursive

