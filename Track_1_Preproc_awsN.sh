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
#Module Loading
#module load Image_Analysis/AFNI
#cd /data/mialab/users/tderamus/Track1_HCP_Brainhack

#ImageTagging
#subjectID=`sed -n ${SLURM_ARRAY_TASK_ID}p ${subIDpath}/derivatives/sublist.txt`
#subPath=${subIDpath}/$subjectID
acqparams=${subPath}/derivatives/acqparams.txt
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

#Bias-Correction SBREF and EPI
mkdir ${subPath}/derivatives/$subjectID
mkdir ${subPath}/derivatives/$subjectID/bias_field
3dcalc -a ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_32CH.nii.gz -b ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_BC.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz -expr 'b/a'
3dWarp -deoblique -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz
mkdir ${subPath}/derivatives/$subjectID/SBRef
3dAutomask -dilate 2 -prefix ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz

3dWarp -oblique_parent $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -gridset $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz
mkdir ${subPath}/derivatives/$subjectID/func

3dcalc -float -a $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS.nii.gz -expr 'a*b*c'

3dcalc  -float  -a $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz -expr 'a*b*c'

#Field Distortion Correction
mkdir ${subPath}/derivatives/$subjectID/fieldmap/

fslmerge -t ${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_3T_Phase_Map.nii.gz $subIDpath/fieldmaps/$subjectID\_3T_SpinEchoFieldMap_LR.nii.gz $subIDpath/fieldmaps/$subjectID\_3T_SpinEchoFieldMap_RL.nii.gz

topup --imain=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_3T_Phase_Map.nii.gz --datain=$acqparams --out=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP --fout=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP_FIELDMAP.nii.gz --iout=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP_CORRECTION.nii.gz

applytopup --imain=${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP --out=${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz

applytopup --imain=${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP --out=${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz

#T1 Corrections and Brain Extraction
mkdir ${subPath}/derivatives/$subjectID/anat

N4BiasFieldCorrection -d 3 -i $subIDpath/anat/$subjectID\_3T_T1w_MPR1.nii.gz -o ${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED.nii.gz
cd /usr/lib/ROBEX
ROBEX ${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED.nii.gz ${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz
cd ${subIDpath}

#Motion Correction and Coregistration using BBR
mkdir ${subPath}/derivatives/$subjectID/coregistration
cd ${subPath}/derivatives/$subjectID/coregistration
mkdir ${subPath}/derivatives/$subjectID/motion

start=`date +%s`

mcflirt -in ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz -reffile ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz -out ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED_MOCO.nii.gz -report

epi_reg --epi=${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz --t1=${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED.nii.gz --t1brain=${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz --out=${subPath}/derivatives/$subjectID/coregistration/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG

c3d_affine_tool -ref ${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz -src ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz ${subPath}/derivatives/$subjectID/coregistration/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG.mat -fsl2ras -oitk ${subPath}/derivatives/$subjectID/coregistration/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG_FSL_to_ANTs_epi_reg.tfm

#Normalization
mkdir ${subPath}/derivatives/$subjectID/normalization
mkdir ${subPath}/derivatives/$subjectID/processed/

antsRegistrationSyN.sh -d 3 -n 8 -f $template -m ${subPath}/derivatives/$subjectID/anat/$subjectID\_T1w_BIAS_CORRECTED_SKULLSTRIPPED.nii.gz -x $templatemask -o ${subPath}/derivatives/$subjectID/normalization/$subjectID\_ANTsReg

antsApplyTransforms -e 3 -i ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED_MOCO.nii.gz -r $template -n BSpline -t ${subPath}/derivatives/$subjectID/normalization/$subjectID\_ANTsReg1Warp.nii.gz -t ${subPath}/derivatives/$subjectID/normalization/$subjectID\_ANTsReg0GenericAffine.mat -t ${subPath}/derivatives/$subjectID/coregistration/$subjectID\_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED_COREG_FSL_to_ANTs_epi_reg.tfm -o ${subPath}/derivatives/$subjectID/processed/$subjectID\_3T_rfMRI_REST1_FULLY_PROCESSED.nii.gz -v

end=`date +%s`
echo $((end-start)) >> ${subPath}/derivatives/$subjectID/benchTime.txt

