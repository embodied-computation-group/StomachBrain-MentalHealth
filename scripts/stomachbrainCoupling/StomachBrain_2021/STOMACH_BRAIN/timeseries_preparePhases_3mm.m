function timeseries_preparePhases_native(subj_idx,cfgMain,error_csf_z)

%{

Load EGG and FMRI timeseries, filter fMRI timeseries at gastric peak, 
extract phases of fmri timeseries(CSFregressed) and save them into
disk in timeseries folder

inputs:
subj_idx = s number
cfgMain must contain fields
    kernelWidth,Timeseries2Regress,frequencySpread ,fOrder,cfgMain.beginCut,cfgMain.endCut

kernelWidth: with of the smoothing kernel from preprocessing, paper  = 3mm

cfgMain.Timeseries2Regress should be 'csf' to load residuals of csf regression
fOrder : mutiplicative factor for the order of the filter
frequencySpread: spead of the time domain filter in hz * 1000, paper = 0.015 hz = 15,

begin and end cut are the voulmes that are discarded to avoid the filter
ringing artifact

cfgMain.transitionWidth is the transition width of the filter, paper is 15


File input: Fullband bold timeseries
Y:\Subjects\Subject13\Timeseries\MRItimeseries\csfRegressionResiduals_FB_S_13_kw3

Output: saves Phase and Amplitude data separatly in subject timeseries folder
Y:\Subjects\Subject13\Timeseries\MRItimeseries\csfResiduals_FB_phases_s13_kw3_fir2_fspread_015

IR COMMENTED 28/06/2017

%}
%% Pass parameters of cfgMain to function

% randomized  = cfgMain.randomized;

%% output filename

disp('+++++++++++++++++++++++++++++++ loading data')

% inputs name

rootDir = global_path2root_folder
dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']
plotDir = dataDir;
plotFilename = strcat(plotDir,'S_',sprintf('%.4d',subj_idx),'_',cfgMain.task,'_MRIPhases3mm');


% Load the information about the peaks of the EGG
EGGPhaseXVolumeFilename = ['/mnt/fast_scratch/StomachBrain/data/EGG_preproc/'...
    ,sprintf('%.4d',subj_idx),'_EGGPhaseXVolume.mat'];
load(EGGPhaseXVolumeFilename)

mostPowerfullFrequency = logEGGpreprocessing.mostPowerfullFrequency;


% nVolumes = size(timeseries.error_csf_z,1)

% Output
BOLDPhasesTimeseriesFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_BOLD_3mm_filtered_CSFREGRESSED_phases']; 


%% Filter-hilbert

disp('+++++++++++++++++++++++++++++++ FILTER HILBERT')

centerFrequency = mostPowerfullFrequency; %
filter_frequency_spread=cfgMain.frequencySpread/1000; % In hz
sr = 1/cfgMain.TR ; % 1 TR = 2s
filterOrder=(cfgMain.fOrder*fix(sr/(centerFrequency-filter_frequency_spread))-1);%in nsamples
transition_width= cfgMain.transitionWidth/100; % in normalised units


filteredMRI=tools_bpFilter(error_csf_z,sr,filterOrder,...
    centerFrequency,filter_frequency_spread,transition_width,cfgMain.filterType);

phaseMRI = angle(hilbert(filteredMRI));
%figure;plot(angle(phaseMRI(:,147)))

    nVolumes = cfgMain.nVolumes; 
    phaseMRI = phaseMRI(cfgMain.beginCut:cfgMain.endCut,:); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
    filteredMRI = filteredMRI(cfgMain.beginCut:cfgMain.endCut,:);

%% Saving

disp('+++++++++++++++++++++++++++++++ SAVING')

%filename_header=[dataDir,'sub-',sprintf('%.4d',subj_idx),'_rest_fprep_nativeV_smooth3mm.nii.gz'] %# list all *.hdr files of preprocessed images, this are the 450 volumes]
%header_nifti =niftiinfo(filename_header);

save(BOLDPhasesTimeseriesFilename,'phaseMRI','-v7.3')
whos phaseMRI
%% Sanity plot
if cfgMain.savePlots == 1

 
    index=tools_getIndexExampleVoxelVMP_3mm(subj_idx);

    
    if cfgMain.plotFigures == 0;
        SanityPlot = figure('visible','off');
    else
        SanityPlot = figure('visible','on');
    end
    
    
    hold on
    subplot(3,1,1)
    plot(error_csf_z(:,index),'r','LineWidth',2)
%     plot(timeseries.BOLD_filtered_zscored(ind_voxelCoordinates_inside,:),'r','LineWidth',2)
    title(['S',sprintf('%.4d',subj_idx),32,'fullband CSF timeseries in rSS'],'fontsize',18)
    grid on
    subplot(3,1,2)
    plot(cfgMain.beginCut:cfgMain.endCut,filteredMRI(:,index),'r','LineWidth',4)
    title(['S',sprintf('%.4d',subj_idx),32,'rSS bandpassfiltered at' 32 num2str(mostPowerfullFrequency)],'fontsize',18)
    grid on
    subplot(3,1,3)
    plot(cfgMain.beginCut:cfgMain.endCut,phaseMRI(:,index),'r','LineWidth',4)
    title(['S',sprintf('%.4d',subj_idx),32,' phases rSS bandpassfiltered at' 32 num2str(mostPowerfullFrequency)],'fontsize',18)
    grid on
    
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'PaperPositionMode', 'auto');
    
    print ('-dpng', '-painters', eval('plotFilename'))
end

end