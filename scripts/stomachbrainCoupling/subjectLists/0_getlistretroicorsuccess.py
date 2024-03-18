import os
import fnmatch

preproc_data_folder='/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/'
subject_list_file = '/home/ignacio/vmp_pipelines_gastro/subjectLists/list_tocopy_subjects.txt'
matched_subjects_file = '/home/ignacio/vmp_pipelines_gastro/subjectLists/list_4clusterretroicor.txt'
unmatched_subjects_file = '/home/ignacio/vmp_pipelines_gastro/subjectLists/list_retroicorfailed.txt'

def list_files(path, pattern):
    full_file_list = []
    for root, dirs, files in os.walk(path):
        for f in files:
            if fnmatch.fnmatch(f, pattern):
                full_path = os.path.join(root, f)
                full_file_list.append(full_path)
    return sorted(full_file_list)

# Get a list of files that match the pattern
file_list = list_files(preproc_data_folder, "*sub*_PLVxVoxel_RP.nii.gz")
print("Contents of the directory:")
print(os.listdir(preproc_data_folder))
print("Lists of files:")
print(file_list)

# Extract the subject index from the file names
def extract_pattern(file_list, pattern):
    extracted_list = []
    for f in file_list:
        if pattern in f:
            start = f.index(pattern) + len(pattern)
            end = start + 4
            extracted_list.append(f[start:end])
    return extracted_list

extracted_list = extract_pattern(file_list, "sub-")
print("Found this pattern in extracted list:")
print(extracted_list)

# Read the list of subjects from the file
with open(subject_list_file) as f:
    subject_list = f.read().splitlines()

# Find the subjects that are in both lists
matched_subjects = sorted(set(subject_list) & set(extracted_list))
print("Matched subjects:")
print(matched_subjects)

# Find the subjects that are in the subject list but not in the extracted list
unmatched_subjects = sorted(set(subject_list) - set(extracted_list))
print("Unmatched subjects:")
print(unmatched_subjects)

# Write the matched and unmatched subjects to files
with open(matched_subjects_file, 'w') as f:
    for subject in matched_subjects:
        f.write("%s\n" % subject)

with open(unmatched_subjects_file, 'w') as f:
    for subject in unmatched_subjects:
        f.write("%s\n" % subject)
