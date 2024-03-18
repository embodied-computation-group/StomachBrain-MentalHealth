function B_Preprocess_EGG(subj_name)

close all

addpath ('/Users/au704655/Documents/Packages/fieldtrip-20220321')
ft_defaults
addpath '/Users/au704655/Documents/EGG/StomachBrain_2021/STOMACH_BRAIN'

root_data_path='/Volumes/Seagate/Physio_VMP/data/Physio_data/EXG/SegmentedEXG/';
fig_save_path='/Users/au704655/Documents/EGG/Figures/';
preproc_save_path='/Users/au704655/Documents/EGG/Preproc/';

%% Load data
if subj_name > 256 %for vmp2 
    subj_filename=[root_data_path,'VMP2_',sprintf('%.4d',subj_name),'_rest.set']
else % for vmp1
    subj_filename=[root_data_path,'VMP_01_',sprintf('%.4d',subj_name),'_rest.set']
end
cfg = [];
cfg.dataset = subj_filename;
EGG_raw = ft_preprocessing(cfg)

if EGG_raw.hdr.nChans == 2
    nChannels = 1; % 1 EGG channel
elseif EGG_raw.hdr.nChans == 4
    nChannels = 3; % 3 EGG channels
elseif EGG_raw.hdr.nChans == 8
    nChannels = 6 ; % 6 EGG channels
end

% flat last channel (sub-0172, sub-0177, sub-0184)
flatchan = []; %3;
%nChannels = nChannels - 1;

%% initialize default filter settings
cfgMain=global_getcfgmain

fOrder = cfgMain.fOrder; % filter order multiplicative factor i.e. 5 = five times number of samples require to sample the slowest frequency
frequencySpread = cfgMain.frequencySpread; %in Hz divided by 1000 e.g. 15 = 0.015 Hz
plotFigures = cfgMain.plotFigures;
beginCut =cfgMain.beginCut; % first and last 21 volumes from the total 600 are discarded systematically after bandpass filtering
endCut = cfgMain.endCut;
automaticChannelSelection = cfgMain.automaticChannelSelection;
offset = cfgMain.offset;

logEGGpreprocessing = []; % initialize log structure

%% load markers

%Markers
cfg = []; %structure de configuration
cfg.dataset = subj_filename; % nom du fichier d'int�r�t
cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
markersInFieldtrip = ft_definetrial(cfg);

%% Downsample data

disp('Resampling...')
cfg = [];  %initialize configuration structure
cfg.detrend = 'no'; % remove linear trend from the data (done per trial)
cfg.demean = 'yes';
cfg.resamplefs= 10; % 4 x top-freq (15 cpm = 0.25 Hz) - Nyquist = 30 cpm  frequency at which the data will be resampled
EGG_downsampled = ft_resampledata(cfg,EGG_raw); % This procedure also lowpass filter the data at half the new sr

% Downsample markers

markersDownsampled = prepro_egg_downsampleMarkers(EGG_raw,EGG_downsampled,markersInFieldtrip);
% Get closest sample number of new marker based on the timestamps of the not downsampled data


%% PLot timeseries

rawtimeseriesplot = figure
for iChannel = 1:nChannels
    if iChannel == flatchan
        continue
    end
    subplot(nChannels,1,iChannel)
    plot(EGG_downsampled.time{1,1}(1,:),EGG_downsampled.trial{1,1}(iChannel,:))
    title(strcat(('Downsampled EGG n'),num2str(iChannel),32,'participant',sprintf('%.2d',subj_name)), 'fontsize',11);
    xlabel('time in s')
    ylabel('amplitude')
    set(gca,'fontsize',12)
    set(gcf,'Position',[1000 1000 1500 15000])
end

RawTimeSeriesFilename = sprintf('%s%.4d_RawTimeSeriesPlot',fig_save_path,subj_name);
if cfgMain.savePlots == 1

    print ('-dpng', '-painters', eval('RawTimeSeriesFilename'))

    print ('-depsc2', '-painters', eval('RawTimeSeriesFilename'))
    saveas(rawtimeseriesplot,strcat(RawTimeSeriesFilename,'.fig'))
end

%% Calculate spectrum

len = EGG_downsampled.fsample*200; % length of subtrials of 200s in samples

EGG_downsampled.sampleinfo=[1 max(EGG_downsampled.time{1,1})*EGG_downsampled.fsample];

cfg = [];
% trl = new trial definition (The first column contains the sample-indices of the start of each trial relative to the start of the raw data, 
% the second column contains the sample indices of the end of each trial, 
% and the third column contains the offset of the trigger with respect to the trial (An offset of 0 means that the first sample of the trial corresponds to the trigger.)
cfg.trl(:,1) = EGG_downsampled.sampleinfo(1):(len/4):EGG_downsampled.sampleinfo(2)-len+1;%trial start in samples from begining of raw data
cfg.trl(:,2) = EGG_downsampled.sampleinfo(1)+len-1:(len/4):EGG_downsampled.sampleinfo(2);%trial ends in samples from begining of raw data
cfg.trl(:,3) = 0; %offset of the trigger with respect to the trial

EGG_trials = ft_redefinetrial(cfg,EGG_downsampled);

%Now we will run a Hann tapered fft on each of the trials, and the resulting power spectra will
% be averaged for us giving a smooth power output
% fft
cfg = [];
cfg.method = 'mtmfft';
cfg.taper = 'hanning';
cfg.output = 'pow';
cfg.pad = 1000; % zero padding - seconds?
cfg.foilim = [0 0.1]; % 0 - 10 cpm
frequencyWelch = ft_freqanalysis(cfg,EGG_trials);

%% Plot spectrum

filterWidth= frequencySpread/1000;% Attention for visualization in the spectrum domain only, filter shape is different

%Welch
% Search for the largest peak in frquencies from 2 to 4 cycles per
% second (normogastria)
indexFrequencies = find (frequencyWelch.freq >= 0.03333 & frequencyWelch.freq <= 0.06666); % normogastria = 2-4 cpm

%Automatically get the channel with highest peak
maxPowerXChannel = zeros(nChannels,2); % column 1 max power, column 2 frequency location
for iChannel=1:nChannels
    if iChannel == flatchan
        continue
    end
    maxPowerXChannel(iChannel,1) = max(frequencyWelch.powspctrm(iChannel,indexFrequencies));% from 0.033 to 0.066 hz
    maxPowerLocation = frequencyWelch.powspctrm(iChannel,:)==maxPowerXChannel(iChannel,1);
    maxPowerXChannel(iChannel,2) = frequencyWelch.freq(find(maxPowerLocation));
end

[highestPower, mostPowerfullChannel] = max(maxPowerXChannel(:,1));
mostPowerfullFrequency = maxPowerXChannel(mostPowerfullChannel,2);

% get index where filter should be ploted
filterPlot=zeros(nChannels,100);
for iChannel=1:nChannels
    if iChannel == flatchan
        continue
    end
    indexFrequenciesFilter = find (frequencyWelch.freq >= maxPowerXChannel(iChannel,2)-filterWidth & frequencyWelch.freq <= maxPowerXChannel(iChannel,2)+filterWidth);
    filterPlot(iChannel,indexFrequenciesFilter)= maxPowerXChannel(iChannel,1);
end

NormogastriaPlot=zeros(nChannels,100);
for iChannel=1:nChannels
    if iChannel == flatchan
        continue
    end
    NormogastriaPlot(iChannel,indexFrequencies)= maxPowerXChannel(iChannel,1);
end

% Which frequency range is going to appear in the plot
%     indexFrequenciesPloting = find (frequencyWelch.freq >= 0.01 & frequencyWelch.freq <= 0.1);
indexFrequenciesPloting = find (frequencyWelch.freq >= 0.0189 & frequencyWelch.freq <= 0.0698);

%
%     if plotFigures == 0;
%         figureSpectrum = figure('visible','off');
%     else
figureSpectrum = figure('visible','on');

for iChannel=1:nChannels
    if iChannel == flatchan
        continue
    end
    subplot(3,2,iChannel);
    plot(frequencyWelch.freq(indexFrequenciesPloting),frequencyWelch.powspctrm(iChannel,indexFrequenciesPloting),'-o','lineWidth',3);
    if iChannel == mostPowerfullChannel
        title(strcat(('Welch EGG n'),num2str(iChannel),32,'participant',sprintf('%.2d',subj_name)),'fontweight','bold', 'fontsize',11);
    else
        title(strcat(('Welch EGG n'),num2str(iChannel),32,'participant',sprintf('%.2d',subj_name)), 'fontsize',11);

    end
    hold on;
    plot (frequencyWelch.freq(indexFrequenciesPloting),filterPlot(iChannel,indexFrequenciesPloting),'r','lineWidth',3)
    plot (frequencyWelch.freq(indexFrequenciesPloting),NormogastriaPlot(iChannel,indexFrequenciesPloting),'k','lineWidth',3)


    set(gca,'fontsize',11)
    xlim([0.0189 0.0698])

    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'PaperPositionMode', 'auto');
   
end

SpectrumFilename = sprintf('%s%.4d_spectrumPlot',fig_save_path, subj_name);
if cfgMain.savePlots == 1

    print ('-dpng', '-painters', eval('SpectrumFilename'))

    print ('-depsc2', '-painters', eval('SpectrumFilename'))
    saveas(figureSpectrum,strcat(SpectrumFilename,'.fig'))
end

%     end %plotFigures

%% select which channel to use
message1=strcat(' Most powerfull channel is channel',32,num2str(mostPowerfullChannel));

%%Manually select witch channel to use

fprintf(message1)

bestChannel = str2double(input('\nEnter the number of the channel you want to use:\n' ,'s'));
mostPowerfullFrequency = maxPowerXChannel(bestChannel,2);

message2=strcat(' Most powerfull frequency in this channel is ',32,num2str(mostPowerfullFrequency),'do you want to use that frequency?');
fprintf(message2)

useAutomaticFrequency = str2double(input('\n if yes enter 1,if Not put the number of the frequency you want to use:\n' ,'s'));
if useAutomaticFrequency ~=1
    mostPowerfullFrequency = useAutomaticFrequency;


    message3=strcat(' The  power is this channel is ',32,num2str(maxPowerXChannel(bestChannel,1))...
        ,32,' and the peak frequency is',32, num2str(mostPowerfullFrequency) );
    fprintf('\n')
    fprintf(message3)


    presstocontinue = str2double(input('\nPress any key to continue:\n' ,'s'));

end % not automatic channel selection

logEGGpreprocessing.confidencechannel_best = str2double(input('\nHow confident you are this is the best channel ?(0 to 1): \n' ,'s'));
logEGGpreprocessing.confidencechannel_quality = str2double(input('\nHow you would rate the quality of the signal of that channel ?(0 to 1): \n' ,'s'));

%% Filter at EGG peak frequency

data=cell2mat(EGG_downsampled.trial);
%     data=data(bestChannel,:);
srate=EGG_downsampled.fsample;
center_frequency=mostPowerfullFrequency + (offset/1000) ;
filter_frequency_spread=frequencySpread / 1000;
% HWHM of the filter, in order to be able to use the
% parameter in the filename, the input to the function is 1000 bigger than
% the actual frequency spead. e.g HWHM 0.005 Hz = frequencySpread=5

lowerFilterBound = center_frequency - filter_frequency_spread; % When filtering starts
filterOrder=fOrder*fix(srate/lowerFilterBound);%in nsamples
transition_width= cfgMain.transitionWidth/100; % in normalised units
[datapoints_EGG_ds_bandpass]= ...
    tools_bpFilter(data',srate,filterOrder,center_frequency,filter_frequency_spread,transition_width,cfgMain.filterType); % filtering
EGG_ds_bandpass = EGG_downsampled; % Copy structure
EGG_ds_bandpass.trial{1,1} = datapoints_EGG_ds_bandpass'; % update actual timeseries


%figure
%plot(EGG_ds_bandpass.trial{1,1}')
%% First downsample, then hilbert, then get mean phase per volume

% Downsample to MRI sampling rate

disp('Resampling...')
cfg = [];  %configuration structure
cfg.detrend = 'no'; % remove linear trend from the data (done per trial)
cfg.demean = 'yes';
cfg.resamplefs= 0.7143; %one volume every 1.4 seconds
EGG_ds_bp_downsampled = ft_resampledata(cfg,EGG_ds_bandpass);

% downsample markers
markers_DS_07143Hz = prepro_egg_downsampleMarkers(EGG_raw,EGG_ds_bp_downsampled,markersInFieldtrip); % Downsample markwers to new SR

% Hilbert transform
phaseEGG = hilbert (EGG_ds_bp_downsampled.trial{1,1}(bestChannel,:));

% Get average phase value per volume
nVolumes=length(markersDownsampled);

phaseXVolume = zeros(1,nVolumes);
for iTrial=1:nVolumes
    phaseXVolume(1,iTrial) = ...
        mean(phaseEGG(1,markers_DS_07143Hz(iTrial,3):markers_DS_07143Hz(iTrial,4)));
end

% Control, check that averaging phase is working
figure
plot(angle(phaseEGG(markers_DS_07143Hz(1,3):end)),'-o')
hold on
plot(angle(phaseXVolume),'-or')


phaseXVolume = phaseXVolume(beginCut:endCut); % cut begining and end of IRM acquisition
EGGTimeseries = EGG_ds_bp_downsampled.trial{1,1}(bestChannel,:);
%     EGGTimeseries = EGGTimeseries(beginCut:endCut);

%     figure
%     plot(EGGTimeseries)
%% Fill log file
EGGPhaseXVolumeFilename = sprintf('%s%.4d_EGGPhaseXVolume',preproc_save_path,subj_name);
EGGAmplitudeXVolumeFilename = sprintf('%s%.4d_AmplitudeXVolume',preproc_save_path,subj_name);
logEGGpreprocessing.subjectNumber = subj_name;
logEGGpreprocessing.cfgMain = cfgMain;
logEGGpreprocessing.mostPowerfullChannel = mostPowerfullChannel;
logEGGpreprocessing.bestChannel = bestChannel;
logEGGpreprocessing.outputFilename = EGGPhaseXVolumeFilename;
logEGGpreprocessing.automaticChannelSelection = cfgMain.automaticChannelSelection;
logEGGpreprocessing.mostPowerfullFrequency = mostPowerfullFrequency;
logEGGpreprocessing.nChannels = nChannels;


%% Plots and sanity check

if plotFigures == 0;
    SanityPlot = figure('visible','off');
else
    SanityPlot = figure('visible','on');
end

% Spectrum best channel unfltered timeseries
subplot(3,1,1)
indexFrequenciesPloting2 = find (frequencyWelch.freq >= 0.035 & frequencyWelch.freq <= 0.065);

plot(frequencyWelch.freq(indexFrequenciesPloting2),frequencyWelch.powspctrm(bestChannel,indexFrequenciesPloting2),'-o','lineWidth',3);

title(strcat(('Welch EGG'),num2str(bestChannel),32,'participant',sprintf('%.2d',subj_name),32,'frequency ',32,num2str(mostPowerfullFrequency)),'fontweight','bold', 'fontsize',11);

set(gca,'fontsize',11)
set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf, 'PaperPositionMode', 'auto');

%     subplot(4,1,2)
%
%     load(strcat('/Users/au704655/Documents/EGG/StomachBrain_2021/STOMACH_BRAIN/files', filesep ,'sampleFieldtripStruc.mat'))
%
%     data = EGGTimeseries;
%     nVoxels = size(data,1);
%
%     % Define fieldtrip structure
%     channelStr=cell(nVoxels,1);
%     for iVoxel = 1:nVoxels
%         channelList(iVoxel,1) = iVoxel;
%         channelStr(iVoxel) = cellstr(mat2str(iVoxel));
%     end
%
%     dataStructure.hdr = EGG_downsampled.hdr;
%     dataStructure.fsample = 1/1.4;
%     dataStructure.time{1,1}  = [0:1.4:(size(data,2)*1.4)-1];
%     dataStructure.label = channelStr;
%     dataStructure.cfg = EGG_downsampled.cfg;
%     dataStructure.trial{1,1} = data;
%
%     len = dataStructure.fsample*120; % length of subtrials cfg.length s in samples
%     dataStructure.sampleinfo=[1 max(dataStructure.time{1,1})*dataStructure.fsample];
%     cfg = [];
%     cfg.trl(:,1) = dataStructure.sampleinfo(1):(len/6):dataStructure.sampleinfo(2)-len+1;%trial start in samples from begining of raw data
%     cfg.trl(:,2) = dataStructure.sampleinfo(1)+len-1:(len/6):dataStructure.sampleinfo(2);%trial ends in samples from begining of raw data
%     cfg.trl(:,3) = 0; %offset of the trigger with respect to the trial
%     data_trials = ft_redefinetrial(cfg,dataStructure);
%
%
%     % Estimate spectrum of filtered timeseries to check if filter worked
%     % properly
%     cfg = [];
%     cfg.method = 'mtmfft';
%     cfg.taper = 'hanning';
%     cfg.output = 'pow';
%     cfg.pad = 1000;
%     cfg.foilim = [1/120 0.1]; % 0 - 6 cpm
%     cfg.keeptrials = 'no';
%
%     frequencyWelchFiltered = ft_freqanalysis(cfg,data_trials);
%
%     indexFrequenciesFiltered = find (frequencyWelchFiltered.freq >= 0.035 & frequencyWelchFiltered.freq <= 0.065);
%
%
%     plot(frequencyWelchFiltered.freq(indexFrequenciesFiltered),frequencyWelchFiltered.powspctrm(indexFrequenciesFiltered),'-o','lineWidth',3);
%
%     title(strcat('Welch EGG',num2str(bestChannel),32,'participant',sprintf('%.2d',subj_name),32,'frequency ',32,num2str(frequencyWelchFiltered.freq(frequencyWelchFiltered.powspctrm == max(frequencyWelchFiltered.powspctrm)))),'fontweight','bold', 'fontsize',11);
%
%

subplot(3,1,2)
%21:1.4:810.600
plot(0:1.4:(length(phaseXVolume)*1.4)-1,angle(phaseXVolume),'-or','lineWidth',2)
title(strcat('PhaseXVolume for subject' ,32,sprintf('%.2d',subj_name),32,'channel ',num2str(bestChannel),32,'frequency ',32,num2str(mostPowerfullFrequency)), 'fontsize',11)

xlabel('S','fontsize',11); ylabel('Angle in radians','fontsize',11);
xlim([0,781.2])

subplot(3,1,3)
plot(EGG_ds_bp_downsampled.time{1},EGGTimeseries,'-ob','lineWidth',2)%plot(30:2:868,EGGTimeseries,'-ob','lineWidth',2)
title(strcat('AmplitudeXVolume for subject' ,32,sprintf('%.2d',subj_name),32,'channel ',num2str(bestChannel),32,'frequency ',32,num2str(mostPowerfullFrequency)), 'fontsize',11)

xlabel('S','fontsize',11); ylabel('Angle in radians','fontsize',11);
xlim([0,781.2])

filteredPlotFilename = sprintf('%s%.4d_filteredPlot', fig_save_path, subj_name);
if cfgMain.savePlots == 1

    print ('-dpng', '-painters', eval('filteredPlotFilename'))

    print ('-depsc2', '-painters', eval('filteredPlotFilename'))
    saveas(SanityPlot,strcat(filteredPlotFilename,'.fig'))
end


logEGGpreprocessing.notes = input('\nAny problems/artefacts or other comments ?: \n' ,'s');

%     logEGGpreprocessing.powerinChosenChannel = maxPowerXChannel(bestChannel,1);
%% Save
save(EGGPhaseXVolumeFilename,'phaseXVolume','logEGGpreprocessing')
save(EGGAmplitudeXVolumeFilename,'EGGTimeseries','logEGGpreprocessing')
save(strcat(EGGPhaseXVolumeFilename,'_log'),'logEGGpreprocessing')


end