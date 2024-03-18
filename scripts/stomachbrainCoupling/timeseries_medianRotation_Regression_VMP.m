function timeseries_medianRotation_Regression_VMP(iSubj)
%{

Stores a .nii image of the median PLV obtained with a timeshifted EGG signals (concatenated and rotated).
It does all 360 possible rotations of EGG signal and calculate PLV at each
rotations and takes the median PLV obtained across timeshift across
voxels to be used as surrogate PLV in group level statistics


inputs:
subj_idx = s number
cfgMainMain must contain fields
    kernelWidth,Timeseries2Regress,frequencySpread ,fOrder,cfgMainMain.beginCut,cfgMainMain.endCut

kernelWidth: with of the smoothing kernel from preprocessing, paper  = 3mm

cfgMainMain.Timeseries2Regress should be 'csf' to load residuals of csf regression
fOrder : mutiplicative factor for the order of the filter
frequencySpread: spead of the time domain filter in hz * 1000, paper = 0.015 hz = 15,

begin and end cut are the voulmes that are discarded to avoid the filter
ringing artifact

cfgMainMain.transitionWidth is the transition width of the filter, paper is 15
offset is with respect to EGG peaking filter, only for control analysis.
offset is in hz x 1000 e.g. and offset of 0.006 hz is a value of 6

Input BOLD timeseries
Y:\Subjects\Subject13\Timeseries\MRItimeseries\csfRegressionResiduals_FB_S_13_kw3

% Output: saves data in subject timeseries folder as a 3D .nii image
Y:\Subjects\Subject13\Timeseries\PhasesAnalysis\medianRotation_csfr_S_13_kw3_fir2_fspread_015_fOrder_5_tw_15

IR commented 28/06/2017

%}
%% Import cfgMain parameters



addpath(genpath('/home/ignacio/vmp_pipelines_gastro/StomachBrain_2021'))
addpath('/mnt/fast_scratch/toolboxes/fieldtrip/');

ft_defaults

cfgMain=global_getcfgmain;

subject_list=load('/home/ignacio/vmp_pipelines_gastro/subjectLists/llist_mainpipelinefailed.txt');

subj_idx = subject_list(iSubj)

fOrder = cfgMain.fOrder;
frequencySpread = cfgMain.frequencySpread;
kernelWidth= cfgMain.kernelWidth;
offset = cfgMain.offset;

%% Define paths and filenames


dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']
plotDir = dataDir;
plotFilename = strcat(plotDir,'S_',sprintf('%.4d',subj_idx),'_',cfgMain.task,'_chancePLVRotationhistogram_RP');

filename_brain_mask = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_brainmask_3mmV.nii.gz']
indBrain= logical(niftiread(filename_brain_mask));
outsideBrain = ~indBrain;

%% Load data and outputfilename
BOLDPhasesTimeseriesFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_BOLD_3mm_filtered_CSFREGRESSED_phases']; 
medianRotationFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_medianRotationRP']; 

load (BOLDPhasesTimeseriesFilename)


EGGPhaseXVolumeFilename = ['/mnt/fast_scratch/StomachBrain/data/EGG_preproc/'...
    ,sprintf('%.4d',subj_idx),'_EGGPhaseXVolume.mat'];
load(EGGPhaseXVolumeFilename)




%% Rotate EGG

indexRotations=round(60/cfgMain.TR):length(phaseXVolume)-round(60/cfgMain.TR); % Rotating at least two minute (30 TR = 60s) at the beggining or end
rotatedPhaseEGG = zeros(length(indexRotations),length(phaseXVolume));
for iRotation = 1 : length(indexRotations)
rotatedPhaseEGG(iRotation,:) = circshift(phaseXVolume,[0 indexRotations(iRotation)]);
end


%% Calculate PLV
disp('+++++++++++++++++++++++++++++++ RPLV')

% initialize structure for distribution of rotated PLV values
RPLV = zeros(length(indexRotations),66*78*66); % R from rotated
%iterate through all rotation and calculate PLV

for iRotation = 1 : length(indexRotations)
    

PLV = zeros (66,78,66);
PLV = PLV(:);

currentPhaseEGG = rotatedPhaseEGG (iRotation,:) ;
phaseDifference = bsxfun (@minus , phaseMRI, angle(currentPhaseEGG )');
PLV(indBrain) =    abs (mean (exp (1i* phaseDifference ) ) ); % 

RPLV(iRotation,:) = PLV;% timeseries_get_PLV(phaseMRI,rotatedPhaseEGG(iRotation,:)'); 

disp('Rotation number for subject:')
disp(iRotation)
disp (subj_idx)
end

%% get and save median rotation

medianPLV= zeros(1,length(RPLV));
medianPLV = median(RPLV,1);

medianPLV(outsideBrain) = 0;
medianPLV = reshape (medianPLV,66,78,66);

niftiheader= (niftiinfo(filename_brain_mask));
niftiheader.Datatype = 'double';
niftiwrite(medianPLV,medianRotationFilename,niftiheader,'Compressed',true)
%% SanityCheck : % check if value of rotation of 

if cfgMain.savePlots == 1
    
%     voxelCoordinates = sub2ind([79,95,79],9,45,53); % voxel in somatomotor cortex
voxelCoordinates = sub2ind([66,78,66],34,17,29);

    voxelCoordinates_inside = zeros(66*78*66,1);
voxelCoordinates_inside(voxelCoordinates)=1;
voxelCoordinates_inside = voxelCoordinates_inside(indBrain);
ind_voxelCoordinates_inside = find(voxelCoordinates_inside);

if cfgMain.plotFigures == 0;
    SanityPlot = figure('visible','off');
else
    SanityPlot = figure('visible','on');
end

% Plot histogram of PLV across the brain

nhist(medianPLV(indBrain))
xlabel('PLV')
title(['S',sprintf('%.4d',subj_idx),32,'surrogatePLV across bain. Mean:' num2str(mean(medianPLV(indBrain)))],'fontsize',18)


set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf, 'PaperPositionMode', 'auto');

print ('-dpng', '-painters', eval('plotFilename'))

end

end