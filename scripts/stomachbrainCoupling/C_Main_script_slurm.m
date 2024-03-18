function C_Main_script_slurm(iSubj)

addpath(genpath('/home/ignacio/vmp_pipelines_gastro/StomachBrain_2021'))
addpath('/mnt/fast_scratch/toolboxes/fieldtrip/');
ft_defaults
cfgMain=global_getcfgmain;

%allSubjs=load('/home/ignacio/vmp_pipelines_gastro/list_clean_subjects.txt');
allSubjs=load('/home/ignacio/vmp_pipelines_gastro/subjectLists/llist_mainpipelinefailed.txt');

subj_idx=allSubjs(iSubj)



try
    %timeseries_gastropipeline_acompcor_native(subj_idx,cfgMain)
    timeseries_gastropipeline_3mm(subj_idx,cfgMain)
catch ME
    fprintf('Error occurred for subj_idx: %d\n', subj_idx);
    % Open file for writing, append failed subj_idx to file
    fileID = fopen(['/home/ignacio/vmp_pipelines_gastro/subjectLists/logs/list_mainpipelinefailed_' num2str(getenv('SLURM_JOB_ID')) '.txt'], 'a');
    fprintf(fileID, '%d\n', subj_idx);
    fclose(fileID);
end


end