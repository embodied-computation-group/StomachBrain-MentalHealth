import os
import fnmatch

# Load the list of subjects to check from the file
with open('list_tocopy_subjects.txt') as f:
    tocopy_subjects = f.read().splitlines()

# Define the path to the directory containing the files to check
data_folder = '/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/'

# Loop over the subjects in the list and check if the file exists for each one
missing_subjects = []
for subject in tocopy_subjects:
    pattern = f'sub-{subject}_PLVxVoxel_3mm.nii.gz'
    file_path = os.path.join(data_folder, f'sub-{subject}', pattern)
    if not os.path.exists(file_path):
        missing_subjects.append(subject)

# Write the missing subjects to a new file
with open('/home/ignacio/vmp_pipelines_gastro/subjectLists/list_missing_files_subjects.txt', 'w') as f:
    for subject in missing_subjects:
        f.write(subject + '\n')
