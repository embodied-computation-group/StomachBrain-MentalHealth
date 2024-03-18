# Scripts for psychiatric stomach-brain coupling CCA

Note: data & scripts for raw/preprocessed fMRI, raw physio, and raw survey individual subject data stored in Visceral Mind Project BIDS structure:

1. Preprocess EGG data for stomach-brain coupling estimation (& compute EGG metrics for physiological control analyses (14.)):
    Psychiatric_StomachBrain/scripts/EGG_preproc_metrics/A_Segment_EGG.m
    Psychiatric_StomachBrain/scripts/EGG_preproc_metrics/B_Preprocess_EGG.m
    Psychiatric_StomachBrain/scripts/EGG_preproc_metrics/C_Compute_EGGmeasures.m

2. Stomach-brain coupling estimation:
    Psychiatric_StomachBrain/scripts/stomachbrainCoupling/0B_tsv2csv_confounds.sh
    Psychiatric_StomachBrain/scripts/stomachbrainCoupling/scriptslurm_reslice_smooth_masksAndBold.sh
    Psychiatric_StomachBrain/scripts/stomachbrainCoupling/scriptslurm_mainpipeline.sh
    Psychiatric_StomachBrain/scripts/stomachbrainCoupling/scriptslurm_surrogatePLV_medianrotation.sh

--------------------------------------------------------------------------------------------------------

3. Prepare stomach-brain coupling (phase locking value) data for CCA (empirical - chance PLV, and DiFuMo parcellate):
    Psychiatric_StomachBrain/scripts/CCA/CCAprepStomachBrain.ipynb

4. Create matched input matrices for CCA (X = stomach-brain coupling, Y = psych data, C = confounds. Outliers removed & participant rows across matrices matched):
    Psychiatric_StomachBrain/scripts/CCA/CCAprepAllData.m

5. X.mat, Y.mat & C.mat from (4.) saved in: 'Psychiatric_StomachBrain/scripts/CCA/cca_pls_toolkit-master/_Project_StomachBrain/data', and framework folder created: '/home/leah/Git/Psychiatric_StomachBrain/scripts/CCA/cca_pls_toolkit-master/_Project_StomachBrain/framework'

6. Run CCA with CCA/PLS toolkit (run on cluster via Psychiatric_StomachBrain/scripts/CCA/cca_pls_toolkit-master/cca_jobs_slurm.sh):
    Psychiatric_StomachBrain/scripts/CCA/cca_pls_toolkit-master/RunCCA.m

7. Plot CCA result (variate scatterplot, psych loading barplot, extraction of cca mode result details):
    Psychiatric_StomachBrain/scripts/CCA/cca_pls_toolkit-master/CCA_plots.m

8. Plot CCA result: stomach-brain coupling loadings projected on DiFuMo parcellated brain:
    Psychiatric_StomachBrain/scripts/CCA/CCA_plotting/CCA_Brain_Figures.ipynb

9. Create averaged summary plots of CCA loadings (for both psych and stomach-brain):
    Psychiatric_StomachBrain/scripts/CCA/CCA_plotting/Averaged_loadings_plots.ipynb

--------------------------------------------------------------------------------------------------------

Extra scripts for control analyses:

Note: data & scripts for preprocessed standard deviation of BOLD, and resting connectivity individual subject data stored in Visceral Mind Project BIDS structure:

10. Prepare control standard deviation of BOLD activity for CCA (DiFuMo parcellate):
    Psychiatric_StomachBrain/scripts/CCA/Control_analyses/ControlCCAs/CCAprepControlSTD.ipynb

11. Create matched input matrices for CCA (X = Control STD BOLD, Y = psych data, C = confounds. Participant rows across matrices matched):
    Psychiatric_StomachBrain/scripts/CCA/Control_analyses/ControlCCAs/CCAprepAllData_controls.m

12. Repeat 5-6 but with results from (11.).

13. Run 11-12 for resting connectivity control CCA (commented in 11. replacing STD BOLD for resting connectvity data).

14. Control Spearman correlations of psychiatric variate from stomach-brain CCA with EGG metrics:
    Psychiatric_StomachBrain/scripts/CCA/Control_analyses/EGGmetric_PsychVariate_Correlations/PsychCCAvariate_EGGmetric_correlations.Rmd

--------------------------------------------------------------------------------------------------------

15. Extra psych plots & diagnosis cutoff percentages script:
    Psychiatric_StomachBrain/scripts/psych_data/psych_inputplots_andcutoffs.Rmd
