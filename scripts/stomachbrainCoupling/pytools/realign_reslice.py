import nibabel as nib
import os as os
from nilearn.image import load_img
from nilearn.image import resample_img

subj_name='sub-0019'
rootFolder='/mnt/fast_scratch/StomachBrain/data/'
path2Bold= os.path.join(rootFolder,'fMRI_timeseries',subj_name,subj_name+'_brainmask_3mmV.nii.gz')
nii_img = load_img(path2Bold)

stat_img=load_img('/home/ignacio/git/fMRIAlertnessDetection/full_template.nii')

# resampled_stat_img = resample_img(stat_img, nii_img)
resampled_stat_img = resample_img(stat_img, target_affine=nii_img.affine, target_shape=nii_img.shape)

original_shape = stat_img.shape
original_affine = stat_img.affine

resampled_shape = resampled_stat_img.shape
resampled_affine = resampled_stat_img.affine

template_shape = nii_img.shape
template_affine = nii_img.affine


print(
    f"""Shape comparison:
- Original t-map image shape : {original_shape}
- Resampled t-map image shape: {resampled_shape}
- Template image shape       : {template_shape}
"""
)

print(
    f"""Affine comparison:
- Original t-map image affine :
 {original_affine}
- Resampled t-map image affine:
 {resampled_affine}
- Template image affine       :
 {template_affine}
"""
)

# Save the aligned and resampled image to disk
stat_img_name='/home/ignacio/git/fMRIAlertnessDetection/full_template_VMP.nii'

nib.save(resampled_stat_img,stat_img_name)
