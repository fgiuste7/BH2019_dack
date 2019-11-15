#! /bin/bash

base_dir='/home/ubuntu/data/'
cd ${base_dir}

subjects=`ls -d ${base_dir}/sub-*`

for subj in ${subjects}; do
	echo "Subject: ${subj}"
	bash ./Fast_Pipeline.sh ${subj} &
done

echo 'WAITING...'
sleep
echo 'DONE'
