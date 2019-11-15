#!/bin/bash
export PATH=${PATH}:/usr/lib/afni/bin:/usr/lib/ROBEX:/usr/lib/ants
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

#ImageTagging
acqparams=${subPath}/derivatives/acqparams.txt
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

mkdir -p ${subPath}/derivatives/${subjectID}/anat

N4BiasFieldCorrection -d 3 -i ${subIDpath}/anat/${subjectID}_3T_T1w_MPR1.nii.gz -o ${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED.nii.gz
cd /usr/lib/ROBEX
ROBEX ${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED.nii.gz ${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz
cd ${subIDpath}

#Normalization
mkdir ${subPath}/derivatives/${subjectID}/normalization
mkdir ${subPath}/derivatives/${subjectID}/processed/

antsRegistrationSyN.sh -d 3 -n 8 -f ${template} -m ${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz -x ${templatemask} -o ${subPath}/derivatives/${subjectID}/normalization/${subjectID}_ANTsReg

endtime=`date +%s`
echo $((endtime-start)) > ${subPath}/derivatives/${subjectID}/step4_benchTime.txt