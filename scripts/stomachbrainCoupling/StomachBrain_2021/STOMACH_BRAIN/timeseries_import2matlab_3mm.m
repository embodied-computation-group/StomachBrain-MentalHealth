function [BOLDtimeseries] =timeseries_import2matlab_3mm(subj_idx,cfgMain)

%{
Construct fMRI timeseries (time,voxels) from swaf images located at each subject folder
and saves them as a structure in the HDD.

Input files
hdr files from each volume
Y:\Subjects\Subject13\fMRI\acquisition1\RestingState\s3wafPHYSIENS_Sujet13-0002-00001-000001-01.hdr

Output 
concatenated MRI timeseries
Y:\Subjects\Subject13\Timeseries\MRItimeseries\fMRItimeseries_S13_kw3.mat

Ignacio Rebollo 16/3/2015
commented 28/06/2017

% Do this in fmriprep native space and not resliced

%}

% kernelWidth = cfgMain.kernelWidth;

% Import


dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']


% create a structure to store the timeseries
BOLDtimeseries = []; % "raw" fmri data
BOLDtimeseries.fsample  = 1/cfgMain.TR;  %0.5 hz, ~ TR=2s


% identify the files corresponding to the deisred spatial kernel smoothing
% obtained from the output from mri preprocessing 

filename=[dataDir,'sub-',sprintf('%.4d',subj_idx),'_rest_fprep_3mmV_smooth3mm.nii.gz'] %# list all *.hdr files of preprocessed images, this are the 450 volumes]
BOLDtimeseries_temp =niftiread(filename);

BOLDtimeseries.anatomy=BOLDtimeseries_temp; clear BOLDtimeseries_temp
dimentions_anatomy=size(BOLDtimeseries.anatomy);
BOLDtimeseries.trialVector=reshape(BOLDtimeseries.anatomy,dimentions_anatomy(1)*dimentions_anatomy(2)*dimentions_anatomy(3),dimentions_anatomy(4));
BOLDtimeseries.anatomy=[];
BOLDtimeseries.time  = [0:cfgMain.TR:cfgMain.nVolumes*cfgMain.TR-1]; % create time axis



end