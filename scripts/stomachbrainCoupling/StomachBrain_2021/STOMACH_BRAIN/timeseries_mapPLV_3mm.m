function timeseries_mapPLV_Regression(subj_idx,cfgMain)
%{
Computes and store in timeseries/data folder a 3D nifti volume with Phase locking value between the EGG and each
voxel timeseries


inputs:
subj_idx = s number
cfgMain must contain fields
    kernelWidth,Timeseries2Regress,frequencySpread ,fOrder,beginCut,endCut
kernelWidth: with of the smoothing kernel from preprocessing, paper  = % 3mm
cfgMain.Timeseries2Regress should be 'csf' to load residuals of csf regression
fOrder : multiplicative factor of the filter order
frequencySpread: spead of the time domain filter in hz * 1000, paper = 0.015 hz = 15,
begin and end cut are the voulmes that are discarded to avoid the filter
ringing artifact
cfgMain.transitionWidth is the transition width of the filter, paper is 15
offset is with respect to EGG peaking filter, only for control analysis.
offset is in hz x 1000 e.g. and offset of 0.006 hz is a value of 6

It's input is the output of the script timeseries_preparePhases_Regression 
Y:\Subjects\Subject13\Timeseries\MRItimeseries\csfResiduals_FB_phases_s13_kw3_fir2_fspread_015
and EGG phases
Y:\Subjects\Subject13\Timeseries\EGGtimeseries\PhaseXvolume_S_13_fir2_fspread_015_ord_5_tw_15

Output: saves data in subject timeseries folder as a 3D .nii image
Y:\Subjects\Subject13\Timeseries\PhasesAnalysis\PLVxVoxel_csfr_S_13_kw3_fir2_fspread_015_fOrder_5_tw_15

It uses mike cohen matlab implementation of PLV (2013)

IR commented on 28/06/2017
%}

%% Pass parameters of cfgMain to function, load data and set output filenames

fOrder = cfgMain.fOrder;
frequencySpread = cfgMain.frequencySpread;
kernelWidth= cfgMain.kernelWidth;

% Get EGG phase x volume

% SubjectDataRoot = [global_path2root,'subject',sprintf('%.4d',subj_idx),filesep,'Timeseries',filesep];
EGGPhaseXVolumeFilename = ['/mnt/fast_scratch/StomachBrain/data/EGG_preproc/'...
    ,sprintf('%.4d',subj_idx),'_EGGPhaseXVolume.mat'];
load(EGGPhaseXVolumeFilename)

% Output filename
rootDir = global_path2root_folder
dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']
plotDir = dataDir;
plotFilename = strcat(plotDir,'sub-',sprintf('%.4d',subj_idx),'_PLVhistogram_RP');


PLVXVoxelFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_PLVxVoxel_RP.nii']; % output filename

% Get BOLD phases
%BOLDPhasesTimeseriesFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'BOLD_filtered_fullband_CSFWMREGRESSED_phases']; 
BOLDPhasesTimeseriesFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_BOLD_3mm_filtered_CSFREGRESSED_phases']; 

load (BOLDPhasesTimeseriesFilename)

filename_brain_mask = ['/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/sub-',sprintf('%.4d',subj_idx),'_brainmask_3mmV.nii.gz'];
indBrain= logical(niftiread(filename_brain_mask));
indNoBrain = ~indBrain;


%% Calculate PLV


% this is hard coded and should be moved to cfg main i.e. the dimensions of
% the fmri volume
empPLV = zeros (66,78,66); % empty 3d Volume for storing empirical PLV
empPLV = empPLV(:); % transformed into a vector
empPLV(indBrain) = abs (mean (exp (1i* (bsxfun (@minus , phaseMRI, angle (phaseXVolume)'))))); % get PLV
% empPLV(indBrain) = abs (mean (exp (1i* (bsxfun (@minus , angle(phaseMRI), angle (phaseXVolume)'))))); % get PLV
% bsxfun applies the operation in @minus from the vector of the third input
% to each column of the matrix of the second input
empPLV(indNoBrain) = 0;
PLV3D = reshape(empPLV,66,78,66); % reshape it from vector to matrix


%% Save data

%tools_writeMri(PLV3D,PLVXVoxelFilename)
niftiheader= (niftiinfo(filename_brain_mask));
niftiheader.Datatype = 'double';
niftiwrite(PLV3D,PLVXVoxelFilename,niftiheader,'Compressed',true)

%% Sanity plot

if cfgMain.savePlots == 1

    index=tools_getIndexExampleVoxelVMP_3mm(subj_idx);
    voxelCoordinates = sub2ind([66,78,66],34,17,29);% for 1mm vmp
    
    if cfgMain.plotFigures == 0;
        SanityPlot = figure('visible','off');
    else
        SanityPlot = figure('visible','on');
    end
    
    % Plot histogram of PLV across the brain
    
    nhist(empPLV(indBrain))
    xlabel('PLV')
    title(['S',sprintf('%.4d',subj_idx),32,'PLV across bain. Mean:' num2str(mean(empPLV(indBrain))) ' rSS voxel:' 32 num2str(empPLV(voxelCoordinates))],'fontsize',18)
    
    
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'PaperPositionMode', 'auto');
    
    print ('-dpng', '-painters', eval('plotFilename'))
    close all
end

end