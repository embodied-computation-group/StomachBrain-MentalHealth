# Purpose: get subject list for which data has been cleaned
import pandas as pd
import os
import fnmatch


# load csv file with subject information in python pandas
csv_file = '/mnt/fast_scratch/StomachBrain/data/EGG_preproc/log_clean.csv'
df = pd.read_csv(csv_file)

preproc_folder='/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/'

'''
def list_files(path, pattern):
    return sorted([f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and fnmatch.fnmatch(f, pattern)])
file_list = list_files(ce_data_folder, "*_rest_fprep_3mmV_smooth3mm*")
'''

def list_files(path, pattern):
    full_file_list = []
    for root, dirs, files in os.walk(path):
        for f in files:
            if fnmatch.fnmatch(f, pattern):
                full_path = os.path.join(root, f)
                full_file_list.append(full_path)
    return sorted(full_file_list)

file_list = list_files(preproc_folder, "*rest_fprep_3mmV_smooth3mm.nii.gz")


print("Contents of the directory:")
print(os.listdir(preproc_folder))

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
print(extracted_list)


df['SubID'] = df['SubID'].astype(str).str.zfill(4)
filtered_df = df[df['SubID'].isin(extracted_list)]
subs_complete_data = filtered_df['SubID'].tolist()
print(subs_complete_data)
len(subs_complete_data)

with open('/home/ignacio/vmp_pipelines_gastro/list_prepro_subjects.txt', 'w') as file:
    for item in subs_complete_data:
        file.write(item + '\n')
