# Purpose: get subject list for which data has been cleaned
import pandas as pd
import os
import fnmatch


# load csv file with subject information in python pandas
csv_file = '/mnt/fast_scratch/StomachBrain/data/EGG_preproc/log_clean.csv'
df = pd.read_csv(csv_file)

# preproc_reslice_data_folder='/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/'
preproc_data_folder='/mnt/raid0/scratch/BIDS/derivatives/fmriprep/'
'''
def list_files(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
file_list = list_files(preproc_reslice_data_folder, "*_rest_fprep_3mmV_smooth3mm*")
'''

def list_files(path, pattern):
    full_file_list = []
    for root, dirs, files in os.walk(path):
        for f in files:
            if fnmatch.fnmatch(f, pattern):
                full_path = os.path.join(root, f)
                full_file_list.append(full_path)
    return sorted(full_file_list)

file_list = list_files(preproc_data_folder, "*sub*ses-session1_task-rest_run-001_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")


print("Contents of the directory:")
print(os.listdir(preproc_data_folder))

print("Lists of files : )")
print(file_list)

def extract_pattern(file_list, pattern):
    extracted_list = []
    for f in file_list:
        if pattern in f:
            start = f.index(pattern) + len(pattern)
            end = start + 4
            extracted_list.append(f[start:end])
    return extracted_list


extracted_list = extract_pattern(file_list, "sub-")

print("Found this pattern in extracted list : )")

print(extracted_list)

# create a list of subjects in df that are in preproc_data_folder

df['SubID'] = df['SubID'].astype(str).str.zfill(4)
filtered_df = df[df['SubID'].isin(extracted_list)]
subs_complete_data = filtered_df['SubID'].tolist()

print("Found this subs_complete_data")

print(subs_complete_data)
len(subs_complete_data)

with open('/home/ignacio/vmp_pipelines_gastro/list_tocopy_subjects.txt', 'w') as file:
    for item in subs_complete_data:
        file.write(item + '\n')

# create a list of subjects in df that are not in preproc_data_folder
not_found_list = []
for subject in df['SubID']:
    if subject not in extracted_list:
        not_found_list.append(subject)

# print the list of subjects not found
print("Subjects not found in preproc_data_folder:")
print(not_found_list)

# write the list of subjects not found to a file
with open('/home/ignacio/vmp_pipelines_gastro/list_missing_subjects.txt', 'w') as file:
    for item in not_found_list:
        file.write(item + '\n')

# Load the contents of both files into Python lists
with open('/home/ignacio/vmp_pipelines_gastro/list_prepro_subjects.txt') as f:
    prepro_subjects = f.read().splitlines()

with open('/home/ignacio/vmp_pipelines_gastro/list_tocopy_subjects.txt') as f:
    tocopy_subjects = f.read().splitlines()

# Find the subjects in tocopy_subjects that are missing in prepro_subjects
toprepro_subjects = [s for s in tocopy_subjects if s not in prepro_subjects]

# Write the missing subjects to a new file
with open('/home/ignacio/vmp_pipelines_gastro/list_toprepro_subjects.txt', 'w') as f:
    for s in toprepro_subjects:
        f.write(s + '\n')
