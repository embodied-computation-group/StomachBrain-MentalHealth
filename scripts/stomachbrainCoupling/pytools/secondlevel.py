import numpy as np
from nilearn.image import resample_to_img
import nibabel as nib
from nilearn.image import concat_imgs
import pandas as pd
import nipype.interfaces.fsl as fsl
from fsl.data import vest
import os
import sys
import pathlib


subjects = np.loadtxt('/home/ignacio/vmp_pipelines_gastro/subjectLists/list_4clusterretroicorMRIQC.txt', dtype=str)

rootFolder = '/mnt/fast_scratch/StomachBrain/data/'


# Create an empty array to store the concatenated difference images
concatenated_diff_images = None

# Loop through each subject
for subject_name in subjects:
    # Construct the file paths for PLV and PLV surrogate
    dataDir = os.path.join(rootFolder, 'fMRI_timeseries', f'sub-{subject_name}')
    filenamePLV = os.path.join(dataDir, f'sub-{subject_name}_PLVxVoxel_RP.nii.gz')
    filenamePLVSurrogate = os.path.join(dataDir, f'sub-{subject_name}_medianRotationRP.nii.gz')

    # Load the PLV and PLV surrogate images
    img_plv = nib.load(filenamePLV)
    img_plv_surrogate = nib.load(filenamePLVSurrogate)

    # Compute the difference between PLV and PLV surrogate
    img_diff = img_plv.get_fdata() - img_plv_surrogate.get_fdata()

    # Concatenate the difference images
    if concatenated_diff_images is None:
        concatenated_diff_images = img_diff
    else:
        concatenated_diff_images = np.concatenate((concatenated_diff_images, img_diff), axis=-1)

# Create a NIfTI image from the concatenated difference images
img_diff_concatenated = nib.Nifti1Image(concatenated_diff_images, affine=img_plv.affine, header=img_plv.header)

# Save the concatenated difference image to a file
output_filename = '/mnt/fast_scratch/StomachBrain/data/groupresults/FSLCluster/difference_concatenated.nii.gz'  
nib.save(img_diff_concatenated, output_filename)



'''



sys.path.insert(0, os.path.dirname(pathlib.Path(__file__).parent.resolve()))
os.chdir(os.path.dirname(pathlib.Path(__file__).parent.resolve()))
from config import preproc_v


MNI_tamplate_path = os.environ['FSL_DIR'] + '/data/standard'
MNI_2mm_mask = nib.load(MNI_tamplate_path + '/MNI152_T1_2mm_brain_mask.nii.gz')

# load and filter the subjects list
record_meta_pd = pd.read_csv('dataframes/egg_brain_meta_data.csv')
if preproc_v == 'strict_gs_cardiac':
    record_meta_pd = record_meta_pd.loc[record_meta_pd['ppu_exclude'] == False, :]
    record_meta_pd = record_meta_pd.loc[record_meta_pd['ppu_found'] == True, :]
subjects_dict = {}
for subject_name in record_meta_pd['subject'].unique():
    subjects_dict[subject_name] = record_meta_pd.loc[(record_meta_pd['subject'] == subject_name),
                                                     'run'].unique()
'''


# compute simple average for each measure
for measure_name in ['plv_delta', 'plv_permut_median', 'plvs_empirical']:
    for subject_index, subject_name in enumerate(subjects_dict.keys()):
        for run_index, run in enumerate(subjects_dict[subject_name]):
            data_path = '../../derivatives/brain_gast/' + subject_name + '/' + subject_name+run
            img_plv = nib.load('../../derivatives/brain_gast/' + subject_name + '/' + subject_name + run +
                               '/' + measure_name + '_' + subject_name + '_run' + run + preproc_v + '.nii.gz')
            if run_index == 0:
                imgs_plv_runs = np.zeros(np.concatenate([[len(subjects_dict[subject_name])], img_plv.shape]))
                if subject_index == 0:
                    MNI_mask_aligned = resample_to_img(MNI_2mm_mask, img_plv, interpolation='nearest')
                    imgs_plv_subjects = np.zeros(np.concatenate([[len(subjects_dict.keys())], img_plv.shape]))
            imgs_plv_runs[run_index,...] = img_plv.get_fdata()
        imgs_plv_runs = imgs_plv_runs.mean(axis=0)
        imgs_plv_runs[MNI_mask_aligned.get_fdata() == 0] = 0
        img_plv_avg = nib.Nifti1Image(imgs_plv_runs, affine=img_plv.affine, header=img_plv.header)
        nib.save(img_plv_avg, '../../derivatives/brain_gast/' + subject_name + '/' +
                 measure_name + '_' + subject_name + '_mean_runs' + preproc_v + '.nii.gz')
        imgs_plv_subjects[subject_index,...] = imgs_plv_runs
    imgs_plv_subjects = imgs_plv_subjects.mean(axis=0)
    img_plv_avg = nib.Nifti1Image(imgs_plv_subjects, affine=img_plv.affine, header=img_plv.header)
    nib.save(img_plv_avg, '../../derivatives/brain_gast/' + measure_name + '_mean_subjects' + preproc_v + '.nii.gz')

## perform Two-Sample Paired T-test - https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Randomise/UserGuide
image_list = []
for measure_name in ['plvs_empirical', 'plv_permut_median']: #'plv_p_vals',
    for subject_index, subject_name in enumerate(subjects_dict.keys()):
        image_list.append(nib.load('../../derivatives/brain_gast/' + subject_name + '/' +
                                   measure_name + '_' + subject_name + '_mean_runs' + preproc_v + '.nii.gz'))

image_4d = concat_imgs(image_list)
nib.save(image_4d, '../../derivatives/brain_gast/fsl_randomize/4d.nii.gz')
nib.save(MNI_mask_aligned, '../../derivatives/brain_gast/fsl_randomize/mask.nii.gz')

n_subjecs = subjects_dict.keys().__len__()
design_mat = np.zeros((n_subjecs*2,n_subjecs + 1))
design_mat[:n_subjecs, 0] = 1
design_mat[n_subjecs:, 0] = -1
design_mat[:n_subjecs, 1:] = np.eye(n_subjecs)
design_mat[n_subjecs:, 1:] = np.eye(n_subjecs)
with open('../../derivatives/brain_gast/fsl_randomize/design.mat', 'w') as text_file:
    text_file.write(vest.generateVest(design_mat))
design_con = np.zeros(n_subjecs + 1)
design_con[0] = 1
with open('../../derivatives/brain_gast/fsl_randomize/design.con', 'w') as text_file:
    text_file.write(vest.generateVest(design_con))
design_grp  = np.concatenate([np.arange(n_subjecs), np.arange(n_subjecs)]) + 1
with open('../../derivatives/brain_gast/fsl_randomize/design.grp', 'w') as text_file:
    text_file.write(vest.generateVest(design_grp[:, np.newaxis]))

rand = fsl.Randomise(in_file=os.path.abspath('../../derivatives/brain_gast/fsl_randomize/4d.nii.gz'),
                     mask = os.path.abspath('../../derivatives/brain_gast/fsl_randomize/mask.nii.gz'),
                     tcon=os.path.abspath('../../derivatives/brain_gast/fsl_randomize/design.con'),
                     design_mat=os.path.abspath('../../derivatives/brain_gast/fsl_randomize/design.mat'),
                     x_block_labels = os.path.abspath('../../derivatives/brain_gast/fsl_randomize/design.grp'),
                     base_name = os.path.abspath('../../derivatives/brain_gast/fsl_randomize/result' + preproc_v + '_'),
                     vox_p_values = True, c_thresh = 2.3, cm_thresh = 2.3, tfce = True,
                     num_perm = 10000)
print(rand.cmdline)
rand.run()

print('Done running the second level analysis code.')
