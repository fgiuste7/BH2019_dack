#!/bin/bash
export PATH=$PATH:/usr/lib/afni/bin:/usr/lib/ROBEX:/usr/lib/ants
export ANTSPATH=/usr/lib/ants
FSLDIR=/usr/share/fsl/5.0 
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
subIDpath=$1
subPath=`dirname ${subIDpath}`
subjectID=`basename ${subIDpath}`
start=`date +%s`

echo "subIDpath: $subIDpath"
echo "subPath: $subPath"
echo "subjectID: $subjectID"

acqparams=${subPath}/derivatives/acqparams.txt
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

#Field Distortion Correction
mkdir -p ${subPath}/derivatives/${subjectID}/fieldmap/

fslmerge -t ${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_3T_Phase_Map.nii.gz ${subIDpath}/fieldmaps/${subjectID}_3T_SpinEchoFieldMap_LR.nii.gz ${subIDpath}/fieldmaps/${subjectID}_3T_SpinEchoFieldMap_RL.nii.gz

topup --imain=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_3T_Phase_Map.nii.gz --datain=${acqparams} --out=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --fout=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP_FIELDMAP.nii.gz --iout=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP_CORRECTION.nii.gz

endtime=`date +%s`
echo $((endtime-start)) > ${subPath}/derivatives/${subjectID}/step2_benchTime.txt