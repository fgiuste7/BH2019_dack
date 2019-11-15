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

#Motion Correction and Coregistration using BBR
mkdir -p ${subPath}/derivatives/${subjectID}/coregistration
cd ${subPath}/derivatives/${subjectID}/coregistration
mkdir ${subPath}/derivatives/${subjectID}/motion

epi_reg --epi=${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz --t1=${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED.nii.gz --t1brain=${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz --out=${subPath}/derivatives/${subjectID}/coregistration/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG

c3d_affine_tool -ref ${subPath}/derivatives/${subjectID}/anat/${subjectID}_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz -src ${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz ${subPath}/derivatives/${subjectID}/coregistration/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG.mat -fsl2ras -oitk ${subPath}/derivatives/${subjectID}/coregistration/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG_FSL_to_ANTs_epi_reg.tfm

#Normalization
antsApplyTransforms -e 3 -i ${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED_MOCO.nii.gz -r ${template} -n BSpline -t ${subPath}/derivatives/${subjectID}/normalization/${subjectID}_ANTsReg1Warp.nii.gz -t ${subPath}/derivatives/${subjectID}/normalization/${subjectID}_ANTsReg0GenericAffine.mat -t ${subPath}/derivatives/${subjectID}/coregistration/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG_FSL_to_ANTs_epi_reg.tfm -o ${subPath}/derivatives/${subjectID}/processed/${subjectID}_3T_rfMRI_REST1_FULLY_PROCESSED.nii.gz -v

endtime=`date +%s`
echo $((endtime-start)) > ${subPath}/derivatives/${subjectID}/step4_benchTime.txt