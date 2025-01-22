% compute instantaneous HRV based on amplitude evelope
clear all; close all
addpath(genpath('/Users/au704655/Documents/StomachBrain/CCA/scripts/Revisions/IgnacioScripts'))
addpath('/Users/au704655/Documents/Packages/fieldtrip-20220321/')
ft_defaults

% these vmp1 subjects use scanner cardiac rather than exg:
vmp1_scanner = ["0021", "0156", "0166", "0169", "0170", "0198", "0200", "0221", "0236", "0246"];

%% load IBIs
% Loop through each IBI file in the folder
for file = dir(fullfile('/Users/au704655/Documents/Physio/InstantaneousHRV/IBI_data/IBIs_RestScanAligned/', '*.*'))' 
    if ~file.isdir %ignores hidden files
        IBIs_path = fullfile(file.folder, file.name); 
        IBIs = IBI_data(:,3);

        subID = file.name(5:8);

        % ensure IBI's are aligned with fmri acquisition
        TR = 1.4;                 % TR in seconds
        n_scans = 600;            % number of scans/volumes
        t = IBI_data(:,2); % make time of each IBI the time of the second R-peak (for each IBI)
        t_fmri = (0:n_scans-1) * TR;  % Time points for each fMRI acquisition
        ibi_fmri = interp1(t, IBIs, t_fmri, 'spline');  % Interpolated IBIs at fMRI times
        % Mark times outside the range of t as NaN (as first/last heartbeat won't necessarily be at the first/last TR)
        ibi_fmri(t_fmri < t(1) | t_fmri > t(end)) = NaN;
        
        cfgMain = global_getcfgmain;
        
        % select non-NaN segment (& remember idx of NaNs for later)
        validMask = ~isnan(ibi_fmri);      % Logical mask for non-NaN values
        ibi_fmri_valid = ibi_fmri(validMask);  % Extract valid segment
        ibi_fmri_valid=detrend(ibi_fmri_valid,'linear');
        
        %% LF HRV
        filter_frequency_spread=0.05; 
        centerFrequency = 0.1; % 0.1 +/- 0.05 = LF band 0.05 to 0.15 Hz (LF = 0.05–0.15 Hz)
        sr = 1; % 1 TR = 1.4s
        filterOrder=(cfgMain.fOrder*fix(sr/(centerFrequency-filter_frequency_spread))-1);%in nsamples
        transition_width= cfgMain.transitionWidth/100; % in normalised units
        LFfilteredHeart=tools_bpFilter(ibi_fmri_valid,sr,filterOrder,centerFrequency,filter_frequency_spread,transition_width,cfgMain.filterType);
        HilbertLFHRV = hilbert(LFfilteredHeart);
        phaseLFHRV = angle(HilbertLFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        AmplitudeEnvelopeLFHRV = abs(HilbertLFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        
        %% HF HRV
        % !! because fMRI TR is 1.4secs - max frequency is 0.357 Hz ( (1/1.4) /2 )(Nyquist theorem)
        % - (thus usual HF win of 0.15-0.4 must be slightly lower 0.357Hz)
        filter_frequency_spread = 0.1035;  % 0.2535 +/- 0.1035 = HF band 0.15 to 0.357 Hz (niquest freq) (HF = 0.15–0.357 Hz)
        centerFrequency = 0.2535;  % Midpoint of the 0.15–0.357 Hz band
        sr = 1; % 1 TR = 1.4s
        filterOrder=(cfgMain.fOrder*fix(sr/(centerFrequency-filter_frequency_spread))-1);%in nsamples
        transition_width= cfgMain.transitionWidth/100; % in normalised units
        HFfilteredHeart=tools_bpFilter(ibi_fmri_valid,sr,filterOrder,centerFrequency,filter_frequency_spread,transition_width,cfgMain.filterType);
        HilbertHFHRV = hilbert(HFfilteredHeart);
        phaseHFHRV = angle(HilbertHFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        AmplitudeEnvelopeHFHRV = abs(HilbertHFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        
        %% ratio
        Ratio_LF2HF = AmplitudeEnvelopeLFHRV./AmplitudeEnvelopeHFHRV;
        
        %% all frequency
        centerFrequency = 0.2035;  % Midpoint of the combined LF (0.05–0.15 Hz) and HF (0.15–0.357 Hz - not 0.4 due to niquest freq) bands
        filter_frequency_spread = 0.1535;  % Half the width of the combined band
        sr = 1; % 1 TR = 1.4s
        filterOrder=(cfgMain.fOrder*fix(sr/(centerFrequency-filter_frequency_spread))-1);%in nsamples
        transition_width= cfgMain.transitionWidth/100; % in normalised units
        AFfilteredHeart=tools_bpFilter(ibi_fmri_valid,sr,filterOrder,centerFrequency,filter_frequency_spread,transition_width,cfgMain.filterType);
        HilbertAFHRV = hilbert(AFfilteredHeart);
        phaseAFHRV = angle(HilbertAFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        AmplitudeEnvelopeAFHRV = abs(HilbertAFHRV); % Cut data to have the same length as EGG (cut this way to get rid of fmri edge artifact on EGG)
        
        %% plot
        figure
        plot(ibi_fmri_valid)
        hold on
        plot(AmplitudeEnvelopeLFHRV,'r')
        plot(AmplitudeEnvelopeHFHRV,'G')
        plot(AmplitudeEnvelopeAFHRV,'C')
        yyaxis right
        plot(Ratio_LF2HF,'k')
        % Add title and axis labels
        title('HRV Amplitude Envelopes');
        % Add a legend
        legend({'IBI Interval', ...
                'LF HRV Amplitude Envelope', ...
                'HF HRV Amplitude Envelope', ...
                'AF HRV Amplitude Envelope', ...
                'LF/HF Ratio'}, ...
                'Location', 'best');
        % Save the figure
        saveas(gcf, sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRV_regressors/Figures/%s_InstHRV.png', file.name(5:8)));  
            
        
        % save amplitude envelopes in fieldtrip format
        load(strcat('/Users/au704655/Documents/StomachBrain/CCA/scripts/Revisions/IgnacioScripts/sampleFieldtripStruc.mat'))
        
        labelsChannelsMAIN = {'LFHRV','HFHRV','RATIO','ALLF'};
        labelsChannels = labelsChannelsMAIN;
        % Account for NaNs at start and end of scan (No IBIs computed)
        clusterRegionsComparisons = NaN(length(labelsChannels), size(validMask,2));
        clusterRegionsComparisons(:,validMask) = [AmplitudeEnvelopeLFHRV; AmplitudeEnvelopeHFHRV; Ratio_LF2HF; AmplitudeEnvelopeAFHRV]; % [AmplitudeEnvelopeLFHRV';AmplitudeEnvelopeHFHRV';Ratio_LF2HF';AmplitudeEnvelopeHFHRV'];
        %dataStructure.hdr = EGG_downsampled.hdr;
        dataStructure.fsample = 1/TR;
        dataStructure.time{1,1}  = t_fmri; %[0:1/dataStructure.fsample:(size(clusterRegionsComparisons,2)-1)/dataStructure.fsample];
        dataStructure.label = labelsChannels;%channelStr;
        %dataStructure.cfg = EGG_downsampled.cfg;
        dataStructure.trial{1,1} = clusterRegionsComparisons;
        dataStructure.sampleinfo = [1 length(clusterRegionsComparisons)];
        
        figure
        %plot(ibi_int)
        hold on
        plot(dataStructure.trial{1,1}(1,:),'-r') %LF
        plot(dataStructure.trial{1,1}(2,:),'-g') %HF
        yyaxis right
        plot(dataStructure.trial{1,1}(3,:),'-k') %Ratio
        % Add title and axis labels
        title('HRV Amplitude Envelopes');
        % Add a legend
        legend({'LF HRV Amplitude Envelope', ...
                'HF HRV Amplitude Envelope', ...
                'LF/HF Ratio'}, ...
                'Location', 'best');
        % Save the figure
        saveas(gcf, sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRV_regressors/Figures/%s_InstHRV_regressors.png', file.name(5:8)));  
        close all;

        % Perform z-scoring only on the non-NaN values
        HFHRVregressor = dataStructure.trial{1,1}(2,:)'; % Initialize to preserve size and NaNs
        HFHRVregressor(validMask) = zscore(HFHRVregressor(validMask));
        
        LFHRVregressor = dataStructure.trial{1,1}(1,:)';        
        LFHRVregressor(validMask) = zscore(LFHRVregressor(validMask));

        RATIOHRVregressor = dataStructure.trial{1,1}(3,:)';
        RATIOHRVregressor(validMask) = zscore(RATIOHRVregressor(validMask));

        AFHRVHRVregressor = dataStructure.trial{1,1}(4,:)';
        AFHRVHRVregressor(validMask) = zscore(AFHRVHRVregressor(validMask));
        
        save(sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRV_regressors/%s_HRV_regressor.mat', subID),'HFHRVregressor','LFHRVregressor','RATIOHRVregressor','AFHRVHRVregressor')
        clearvars -except file vmp1_scanner 
    end
end


% % check lengths
% folder_path = '/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRV_regressors/';  % Update with your folder path
% mat_files = dir(fullfile(folder_path, '*_HRV_regressor.mat'));
% for k = 1:length(mat_files)
%     data = load(fullfile(folder_path, mat_files(k).name));
%     if length(data.HFHRVregressor) < 596 || length(data.HFHRVregressor) > 600
%         print(fprintf('File: %s regressor length: %d', mat_files(k).name, length(data.HFHRVregressor)))
%     end
% end




