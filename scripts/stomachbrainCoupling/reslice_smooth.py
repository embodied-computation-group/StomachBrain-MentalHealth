# %%
import nibabel.processing as nibp
import nibabel as nib
import numpy as np
import os
import fnmatch
import sys

# %%

iSubj = sys.argv[1]
print("The input value is:", iSubj)

# %%  Set paths and subjects list
fmriprep_folder='/mnt/fast_scratch/StomachBrain/data/allpreprocRest/'
raw_BOLD='ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'
output_data_folder='/mnt/fast_scratch/StomachBrain/data/'


# %% Make subject folders

with open('/home/ignacio/vmp_pipelines_gastro/list_toprepro_subjects.txt', 'r') as file:
    list_subjects = [line.strip() for line in file.readlines()]
subj_name="sub-"+list_subjects[int(iSubj)]    


path2output=os.path.join(output_data_folder,'fMRI_timeseries',subj_name)
path2imageSlicedSmoothed= os.path.join(output_data_folder,'fMRI_timeseries',subj_name,subj_name+'_rest_fprep_3mmV_smooth3mm.nii.gz')

print (path2output)

isExist = os.path.exists(path2output)
if isExist==False:
    os.makedirs(path2output)
    
# %% Load and smooth

if os.path.exists(path2imageSlicedSmoothed):
    print("File already exists, skipping...")
else:
    path2imageraw= os.path.join(fmriprep_folder,subj_name+'_ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz')
    print(path2imageraw)
    print(subj_name)
    img = nib.load(path2imageraw)
    img_smoothed= nibp.smooth_image(img, 3)
    # Get the data, affine transformation and voxel sizes
    data = img_smoothed.get_fdata()
    affine = img_smoothed.affine
    voxel_size = img_smoothed.header.get_zooms()[:3]
    new_voxel_size=(3,3,3)


    # Reslice to 3mm voxels
    resampled_data = np.zeros([66, 78, 66,600])

    for i in range(data.shape[-1]):
        vol = nib.Nifti1Image(data[..., i], affine)
        resampled_vol = nib.processing.resample_to_output(vol, new_voxel_size)
        resampled_data[..., i] = resampled_vol.get_fdata()

    #Recompute affine for new size
    ratio = np.array(new_voxel_size) / np.array(voxel_size)
    new_affine=affine
    new_affine[:3, :3] = new_affine[:3, :3] * ratio

    # store in disk
    resampled_img = nib.Nifti1Image(resampled_data, new_affine)
    nib.save(resampled_img,path2imageSlicedSmoothed)

print('Im done')

