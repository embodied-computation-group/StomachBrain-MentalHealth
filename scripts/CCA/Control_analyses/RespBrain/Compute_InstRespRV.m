% compute instantaneous Respiratory Rate Variability based on amplitude evelope
clear all; close all
addpath(genpath('/home/leah/Git/StomachBrain-MentalHealth/scripts/CCA/Control_analyses/HeartBrain/ToolScripts'))
ft_defaults

%% compute respiratory inhalation intervals

%% load inhalation peak-peak durations
% Loop through each IBI file in the folder
Respfiles = dir(fullfile('/mnt/raid0/scratch/BIDS/derivatives/physio/resp/rest/BreathDetails/*'));
for n = 1:length(Respfiles)
    file = Respfiles(n);
    if ~file.isdir %ignores hidden files
        Breaths_path = fullfile(file.folder, file.name); 
        Breaths_data = readtable(Breaths_path);
        Breath_durations = table2array(Breaths_data(:,6)); % inhalation peak to inhalation peak durations

        subID = file.name(1:4);
        
        if str2num(subID) <= 262
            sfreq = 1000;
        else
            sfreq = 50;
        end

        % ensure breath's are aligned with fmri acquisition
        TR = 1.4;                 % TR in seconds
        n_scans = 600;            % number of scans/volumes
        t = table2array(Breaths_data(:,4))/sfreq; % make time of each RespInterval the time of the second inhalation-peak 
        t_fmri = (0:n_scans-1) * TR;  % Time points for each fMRI acquisition
        Breathdurations_fmri = interp1(t, Breath_durations, t_fmri, 'spline');  % Interpolated IBIs at fMRI times
        % Mark times outside the range of t as NaN (as first/last inhalation won't necessarily be at the first/last TR)
        Breathdurations_fmri(t_fmri < t(1) | t_fmri > t(end)) = NaN;
       
        cfgMain = global_getcfgmain;
        
        % select non-NaN segment (& remember idx of NaNs for later)
        validMask = ~isnan(Breathdurations_fmri);      % Logical mask for non-NaN values
        Breathdurations_fmri_valid = Breathdurations_fmri(validMask);  % Extract valid segment
        Breathdurations_fmri_valid=detrend(Breathdurations_fmri_valid,'linear');
        
        %% Respiratory Rate Variability
        filter_frequency_spread=0.1285; 
        centerFrequency = 0.2285; % 0.2285 +/- 0.1285 = Freqs 0.1 to 0.357 Hz (6 to 21.4 breaths per min) (0.357 Hz limit due to niquest freq) 
        sr = 1; % 1 TR = 1.4s
        filterOrder=(cfgMain.fOrder*fix(sr/(centerFrequency-filter_frequency_spread))-1);%in nsamples
        transition_width= cfgMain.transitionWidth/100; % in normalised units
        filteredBreath=tools_bpFilter(Breathdurations_fmri_valid,sr,filterOrder,centerFrequency,filter_frequency_spread,transition_width,cfgMain.filterType);
        HilbertBreath = hilbert(filteredBreath);
        phaseLFBreath = angle(HilbertBreath); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        AmplitudeEnvelopeBreath = abs(HilbertBreath); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
 
        %% plot
        figure
        plot(filteredBreath)
        hold on
        plot(AmplitudeEnvelopeBreath,'r')
        plot(Breathdurations_fmri_valid)
        % Add title and axis labels
        title('Resp Amplitude Envelope');
        % Add a legend
        legend({'Breath Filtered', ...
                'Breath Amplitude Envelope', ...
                'Breath Durations'}, ...
                'Location', 'best');
        % Save the figure
        saveas(gcf, sprintf('/mnt/raid0/scratch/BIDS/derivatives/physio/resp/rest/RespRegressors/Figures/%s_InstRespVariability.png', file.name(5:8)));  
            
        % Perform z-scoring only on the non-NaN values
        RespVregressor = NaN(length(Breathdurations_fmri),1); % Initialize to preserve size and NaNs
        RespVregressor(validMask) = zscore(AmplitudeEnvelopeBreath);
       
        save(sprintf('/mnt/raid0/scratch/BIDS/derivatives/physio/resp/rest/RespRegressors/%s_RespVariability_regressor.mat', subID),'RespVregressor')
        clearvars -except Respfiles 
    end
end

