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

#Bias-Correction SBREF and EPI
mkdir -p ${subPath}/derivatives/${subjectID}/bias_field/

3dcalc -a ${subIDpath}/biasmaps/${subjectID}_3T_BIAS_32CH.nii.gz -b ${subIDpath}/biasmaps/${subjectID}_3T_BIAS_BC.nii.gz -prefix ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_bias_field.nii.gz -expr 'b/a'

3dWarp -deoblique -prefix ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_bias_field_deobl.nii.gz ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_bias_field.nii.gz

mkdir -p ${subPath}/derivatives/${subjectID}/SBRef

3dAutomask -dilate 2 -prefix ${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ${subIDpath}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef.nii.gz

3dWarp -oblique_parent ${subIDpath}/func/${subjectID}_3T_rfMRI_REST1_LR.nii.gz -gridset ${subIDpath}/func/${subjectID}_3T_rfMRI_REST1_LR.nii.gz -prefix ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_bias_field_deobl.nii.gz
mkdir -p ${subPath}/derivatives/${subjectID}/func

3dcalc -float -a ${subIDpath}/func/${subjectID}_3T_rfMRI_REST1_LR.nii.gz -b ${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS.nii.gz -expr 'a*b*c'

3dcalc  -float  -a ${subIDpath}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef.nii.gz -b ${subPath}/derivatives/${subjectID}/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/${subjectID}/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz -expr 'a*b*c'

endtime=`date +%s`
echo $((endtime-start)) > ${subPath}/derivatives/${subjectID}/step1_benchTime.txt