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
acqparams=${subPath}/derivatives/acqparams.txt
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz


applytopup --imain=${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS.nii.gz --inindex=1 --method=jac --datain=${acqparams} --topup=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --out=${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz

applytopup --imain=${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz --inindex=1 --method=jac --datain=${acqparams} --topup=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --out=${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz


mcflirt -in ${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz -reffile ${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz -out ${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED_MOCO.nii.gz -report
