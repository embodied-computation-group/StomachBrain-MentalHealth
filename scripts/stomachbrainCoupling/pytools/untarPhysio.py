import os
import csv
import gzip

# Path to the list of subjects
subjects_file = "/home/ignacio/vmp_pipelines_gastro/subjectLists/list_tocopy_subjects.txt"

# Path to the root directory where the gzip files are located
root_dir = "/mnt/raid0/scratch/BIDS"

# Path to the directory where the CSV files will be saved
output_dir = "/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries"

# Path to the file where the list of subjects without gzip files will be saved
no_gzip_file_path = "/home/ignacio/vmp_pipelines_gastro/subjects_without_gzip_files.txt"

# Add the "sub-" prefix to the subject IDs once before the loop
with open(subjects_file, "r") as f:
    subject_ids = ["sub-" + subject.strip() for subject in f]

# Loop through each subject ID
for subject_id in subject_ids:
    print(f"Processing subject {subject_id}...")

    # Define the path to the gzip file for this subject
    gzip_file_path = os.path.join(root_dir, subject_id, "ses-session1", "func",
                                 f"{subject_id}_ses-session1_task-rest_run-001_recording-exg_physio.tsv.gz")

    # Check if the gzip file exists
    if not os.path.exists(gzip_file_path):
        with open(no_gzip_file_path, "a") as f:
            f.write(subject_id + "\n")
        continue
    
    # Define the path to the CSV file for this subject
    csv_file_path = os.path.join(output_dir, subject_id, f"{subject_id}_rest_run-001_physio.csv")

    # Check if the CSV file already exists
    if os.path.exists(csv_file_path):
        print(f"CSV file already exists for subject {subject_id}")
        continue
    
    # Open the gzip file and extract the TSV file
    try:
        with gzip.open(gzip_file_path, "rt") as gzip_file:
            tsv_reader = csv.reader(gzip_file, delimiter="\t")

            # Save the TSV data to CSV format and save it to disk
            os.makedirs(os.path.dirname(csv_file_path), exist_ok=True)
            with open(csv_file_path, "w", newline="") as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=",")
                for row in tsv_reader:
                    csv_writer.writerow(row)
    except Exception as e:
        print(f"Error processing subject {subject_id}: {e}")
        with open(no_gzip_file_path, "a") as f:
            f.write(subject_id + "\n")
