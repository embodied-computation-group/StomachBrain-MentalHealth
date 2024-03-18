function global_createSubjectFolder(subj_idx,sample)

rootDir= strcat(global_path2root);
% 



mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Brainamp',filesep,'REST'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Plots'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep,'EGGTimeseries',filesep,'REST'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep,'MRItimeseries',filesep,'REST'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep,'PhasesAnalysis'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep,'PhasesAnalysis',filesep,'REST'))
mkdir(strcat(rootDir,'Subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep,'ControlEGG_othersubject'))






