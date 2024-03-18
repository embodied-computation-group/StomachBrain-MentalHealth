# %%
import nibabel.processing as nibp
import nibabel as nib
import numpy as np
import os
import fnmatch
import sys

# %%
# iSubj=0
iSubj = sys.argv[1]
print("The input value is:", iSubj)

# %%  Set paths and subjects list
fmriprep_folder='/mnt/fast_scratch/StomachBrain/data/allpreprocRest/'
# raw_BOLD='ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'
output_data_folder='/mnt/fast_scratch/StomachBrain/data/'

'''
def list_folders(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
folder_list = list_folders(fmriprep_folder, "sub*")

def list_files(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
file_list = list_files(fmriprep_folder, "*sub*desc-brain_mask.nii.gz")
'''

# print(file_list)



# %% Make subject folders
with open('/home/ignacio/vmp_pipelines_gastro/list_toprepro_subjects.txt', 'r') as file:
    list_subjects = [line.strip() for line in file.readlines()]
subj_name="sub-"+list_subjects[int(iSubj)]    

path2output=os.path.join(output_data_folder,'fMRI_timeseries',subj_name)

print (path2output)

isExist = os.path.exists(path2output)
if isExist==False:
    os.makedirs(path2output)
    
# %%  Load and smooth
path2imageSliced= os.path.join(output_data_folder,'fMRI_timeseries',subj_name,subj_name+'_brainmask_3mmV.nii.gz')
path2imageraw= os.path.join(fmriprep_folder,subj_name+'_ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz')
print(path2imageraw)
print(subj_name)

if os.path.exists(path2imageSliced):
    print("File already exists, skipping...")
else:

    img = nib.load(path2imageraw)


    affine = img.affine
    voxel_size = img.header.get_zooms()[:3]
    new_voxel_size=(3,3,3)

    resampled_vol = nib.processing.resample_to_output(img, new_voxel_size)

    '''
    # Reslice to 3mm voxels
    resampled_data = np.zeros([66, 78, 66])
    resampled_vol = nib.processing.resample_to_output(vol, new_voxel_size)
    resampled_data[..., i] = resampled_vol.get_fdata()
    '''

    #Recompute affine for new size
    ratio = np.array(new_voxel_size) / np.array(voxel_size)
    new_affine=affine
    new_affine[:3, :3] = new_affine[:3, :3] * ratio

    #  store in disk


    resampled_vol_2save=resampled_vol.get_fdata()
    resampled_img = nib.Nifti1Image(resampled_vol_2save, new_affine)

    #save the image in nifti format in hardrive
    nib.save(resampled_img,path2imageSliced)


    print('Im done')



