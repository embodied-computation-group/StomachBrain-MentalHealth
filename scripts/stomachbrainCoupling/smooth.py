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
raw_BOLD='ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
output_data_folder='/mnt/fast_scratch/StomachBrain/data/'

'''
def list_folders(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
folder_list = list_folders(fmriprep_folder, "sub*")
'''

'''
def list_files(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
file_list = list_files(fmriprep_folder, "*sub*ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")
print(file_list)
'''


# %% Make subject folders
'''
subj_name=file_list[int(iSubj)]
subj_name=subj_name[0:8]
print(subj_name)
'''

with open('/home/ignacio/vmp_pipelines_gastro/list_clean_subjects.txt', 'r') as file:
    list_subjects = [line.strip() for line in file.readlines()]
subj_name="sub-"+list_subjects[int(iSubj)]    

path2output=os.path.join(output_data_folder,'fMRI_timeseries',subj_name)
path2imageSmoothed= os.path.join(output_data_folder,'fMRI_timeseries',subj_name,subj_name+'_rest_fprep_nativeV_smooth3mm')

print (path2output)

# %% Check if folder exists, if not, create it and run
isExist = os.path.exists(path2output)
if isExist==False:
    os.makedirs(path2output)

if os.path.exists(path2imageSmoothed):
    print("File already exists, skipping...")
else:
    #Save in gzip format
    path2imageSmoothed= os.path.join(output_data_folder,'fMRI_timeseries',subj_name,subj_name+'_rest_fprep_nativeV_smooth3mm.nii.gz')

    # Load and smooth
    path2imageraw= os.path.join(fmriprep_folder,subj_name+'_ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz')
    print(path2imageraw)
    print(subj_name)
    img = nib.load(path2imageraw)
    img_smoothed= nibp.smooth_image(img, 3)

    # store in disk


    nib.save(img_smoothed,path2imageSmoothed)

    print('Im done')


# %%
