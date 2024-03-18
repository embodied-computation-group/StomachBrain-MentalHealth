function [residuals_z] =timeseries_preprocessBOLD_3mm(subj_idx,cfgMain,BOLDtimeseries)

%{

Takes the output of timeseries_prepare_import2matlab that is stored in 
each subject timeseries\data folder 
Y:\Subjects\Subject13\Timeseries\MRItimeseries\fMRItimeseries_S13_kw3.mat

and preprocess it so it can be further analyzed
Preprocessing steps, implemented in fieldtrip, includes remove polinomial trends of second degree,
bandpass filter between 0.01 and 0.1 Hz and standarize to Z units
the output is stored in the tiemseries folder of each subject
Y:\Subjects\Subject13\Timeseries\MRItimeseries\BOLDFULLBAND_S13_kw3


% IR commented on the 12/09/2016
% recommented 28/06/2017

%}

rootDir = global_path2root_folder
dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']
plotDir = dataDir;
regressorsfmriprep=readtable(['/mnt/fast_scratch/StomachBrain/data/allpreprocRest/sub-',sprintf('%.4d',subj_idx),'_ses-session1_task-rest_run-001_desc-confounds_timeseries.csv']);
filename_brain_mask = ['/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/sub-',sprintf('%.4d',subj_idx),'_brainmask_3mmV.nii.gz'];

insideBrain= logical(niftiread(filename_brain_mask));
plotFilename = strcat(plotDir,'S_',sprintf('%.4d',subj_idx),'_',cfgMain.task,'_ACOMPCORregression3mm');


path_retroicor = strcat('/mnt/raid0/scratch/BIDS/derivatives/retroicor/','sub-',sprintf('%.4d',subj_idx),filesep);


% CORRECT HERE, MANUALLY CHANGED rest_modality-exg_confounds TO rest_modality-scanner_confounds
% corrected with try catch, but uncomment eval and input path to transform t ocsv
%inputTSV= strcat(path_retroicor,'task-rest_modality-scanner_confounds.tsv');
outputCSVScanner=strcat(path_retroicor,'task-rest_modality-scanner_confounds.csv');
outputCSVECG=strcat(path_retroicor,'task-rest_modality-exg_confounds.csv');

if isfile(outputCSVScanner)
fil2load=outputCSVScanner
elseif isfile(outputCSVECG)
    fil2load=outputCSVECG
else

    display('Sorry')
    
    return
end
%command2bash =['! python /home/ignacio/vmp_pipelines_gastro/0B_tsv2csv.py <','"',inputTSV,'" > "',outputCSV,'"'];
%eval(command2bash)

retroicor=readtable(fil2load);


regressors=[table2array(retroicor),regressorsfmriprep.trans_x,regressorsfmriprep.trans_y,...
regressorsfmriprep.trans_z,regressorsfmriprep.rot_x,regressorsfmriprep.rot_y,regressorsfmriprep.rot_z,regressorsfmriprep.a_comp_cor_00,regressorsfmriprep.a_comp_cor_01,regressorsfmriprep.a_comp_cor_02,regressorsfmriprep.a_comp_cor_03,regressorsfmriprep.a_comp_cor_04,regressorsfmriprep.a_comp_cor_05];


% Remove confounds from BOLD timeseries
toBeExplained = double(BOLDtimeseries.trialVector(insideBrain,:))'; % BOLD timeseries will be the variable to be explained out in the GLM
betas_acompcor = tools_EfficientGLM(toBeExplained,regressors); % Obtain the betas indicating how much the predicting variable predicts the data
predictedBOLD = regressors*betas_acompcor; % What the BOLD timeseries should look like if CSF predicted at 100% accuracy the data
toBeExplained_z= zscore(toBeExplained,[],1);
predictedBOLD_z= zscore(predictedBOLD,[],1);
residuals = toBeExplained_z - predictedBOLD_z; % The error is the portion of the data not predicted by the CSF signal
residuals_z = zscore(residuals,[],1);


%% Sanity check

if cfgMain.savePlots == 1
    
    if cfgMain.plotFigures == 0;
        SanityPlot = figure('visible','off');
    else
        SanityPlot = figure('visible','on');
    end
    
    index=tools_getIndexExampleVoxelVMP_3mm(subj_idx);


    plot(toBeExplained_z(:,logical(index)),'r-','LineWidth',4)
    hold on
    plot(predictedBOLD_z(:,logical(index)),'b-','LineWidth',4)
    plot(residuals_z(:,logical(index)),'g-','LineWidth',4)

    legend ('toBeExplained_z','predictedBOLD_z','residuals_z')

    subplot(3,1,3)
    plot(toBeExplained_z(:,logical(index)),'r-','LineWidth',4)
    hold on
    plot(residuals_z(:,logical(index)),'b-','LineWidth',3)
    grid on
    legend ('Before regression','After regression')
    title(['S',sprintf('%.4d',subj_idx),32,'EFFects of CSF regression in occipital'],'fontsize',18)
       
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'PaperPositionMode', 'auto');
    
    print ('-dpng', '-painters', eval('plotFilename'))
    close all
end

end