%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SCRIPT_EGG_main
%%% 
%%% This script calls the functions needed for EGG preprocessing, artifact 
%%% detection and EGG analysis.
%%% When using this function in any published study, please cite: Wolpert, 
%%% N., Rebollo, I., Tallon-Baudry, C. (2020). Electrogastrography for 
%%% psychophysiological research: practical considerations, analysis pipeline 
%%% and normative data in a large sample. Psychophysiology (in press)
%%%
%%% The scripts and functions were written in Matlab version R2017b.
%%%
%%% These functions make use of the fieldtrip toolbox, version 20170315
%%% (see http://www.fieldtriptoolbox.org/).
%%% Reference:
%%% Robert Oostenveld, Pascal Fries, Eric Maris, and Jan-Mathijs Schoffelen. 
%%% FieldTrip: Open Source Software for Advanced Analysis of MEG, EEG, and 
%%% Invasive Electrophysiological Data. Computational Intelligence and 
%%% Neuroscience, vol. 2011, Article ID 156869, 9 pages, 2011. 
%%% doi:10.1155/2011/156869.
%%% 
%%% The code comes with example of EGG datasets (EGG_raw_example1/2/3.mat).
%%% The files contains 7 channels of EGG recorded for approximately 12 
%%% minutes using a Biosemi amplifier (sampling rate: 1kHz).
%%%
%%% Copyright (C) 2019, Laboratoire de Neurosciences Cognitives, Nicolai 
%%% Wolpert, Ignacio Rebello & Catherine Tallon-Baudry
%%% Email: nicolaiwolpert@gmail.com
%%% 
%%% DISCLAIMER:
%%% This code is provided without explicit or implicit guarantee, and 
%%% without any form of technical support. The code is not intended to be 
%%% used for clinical purposes. The functions are free to use and can be
%%% redistributed, modified and adapted, under the terms of the CC BY-NC-SA
%%% version of creative commons license (see
%%% <https://creativecommons.org/licenses/>).
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1) Initialization
clear all; close all;
clc

% add fieldtrip toolbox to path
fieldtrip_path = '/Users/au704655/Documents/Packages/fieldtrip-20220321';
addpath(fieldtrip_path);
ft_defaults;
% add EGG functions to path 
script_path = '/Users/au704655/Documents/EGG/Scripts/NiWolpert_EGG_Scripts/';
addpath(script_path);

folderpath = '/Users/au704655/Documents/EGG/Preproc/';
folderpath = fullfile(folderpath, '*_log.mat');    % What is the meaning of "/**/" ???
filelist   = dir(folderpath);
name       = {filelist.name};
name       = name(~strncmp(name, '.', 1))   % No files starting with '.'

subj_id=[]
for n = 1:length(name)
    subj_id(n) = str2num(name{n}(1:4))
end
 %check sub-0144 (subj = 112) %check sub-0431 (subj=238) %sub-0443 (subj=248)
for subj = 112:length(subj_id)

    % specify location of scripts and data files
    subj_name = subj_id(subj);
    root_data_path='/Volumes/Seagate/Physio_VMP/data/Physio_data/EXG/SegmentedEXG/';
    if subj_name > 256
        file_name=[root_data_path,'VMP2_',sprintf('%.4d',subj_name),'_rest.set'];
    else % for vmp1
        file_name=[root_data_path,'VMP_01_',sprintf('%.4d',subj_name),'_rest.set'];
    end
    
    % Load EGG raw data.
    % A dataset in fieldtrip format (e.g. output of 'ft_preprocessing') is expected here. 
    % For an overview of fieldtrip-compatible dataformats see:
    % http://www.fieldtriptoolbox.org/faq/dataformat/
    % 
    % As a reminder, EGG data should be recorded without highpass-filter (DC recording)
    % and referenced in an appropriate manner. 
    % For more information on reading, filtering and re-referencing with fieldtrip, 
    % see: http://www.fieldtriptoolbox.org/tutorial/continuous/
    
    %% load raw EGG
    cfg = [];
    cfg.dataset = file_name;    
    EGG_raw = ft_preprocessing(cfg);
    
    %% select best channel we manually selected
    % load log
    load(sprintf('/Users/au704655/Documents/EGG/Preproc/%.4d_EGGPhaseXVolume_log.mat',subj_name))
    cfg.channel = logEGGpreprocessing.bestChannel;
    EGG_raw = ft_selectdata(cfg, EGG_raw);
    
    %% Power spectrum, channel selection
    % Compute the EGG power spectrum for all channels and select the channel
    % with the strongest peak between 0.033 and 0.067 Hz.
    
    [FFT_EGG] = compute_FFT_EGG_LB(EGG_raw, 0);
    
    log.peak_freq_norm = FFT_EGG.max_freq_norm; % peak frequency
    log.max_power_norm = FFT_EGG.max_pow_max_chan_norm; % power (maximum)
    log.mean_power_norm = FFT_EGG.mean_power_norm;
    log.prop_power_norm = FFT_EGG.prop_power_norm;
    log.peak_freq_brady = FFT_EGG.max_freq_brady; % peak frequency
    log.max_power_brady = FFT_EGG.max_pow_max_chan_brady; % power (maximum)
    log.mean_power_brady = FFT_EGG.mean_power_brady;
    log.prop_power_brady = FFT_EGG.prop_power_brady;
    log.peak_freq_tachy = FFT_EGG.max_freq_tachy; % peak frequency
    log.max_power_tachy = FFT_EGG.max_pow_max_chan_tachy; % power (maximum)
    log.mean_power_tachy = FFT_EGG.mean_power_tachy;
    log.prop_power_tachy = FFT_EGG.prop_power_tachy;
    log.mean_power_ratio_norm = FFT_EGG.mean_power_ratio_norm;
    log.mean_power_ratio_brady = FFT_EGG.mean_power_ratio_brady;
    log.mean_power_ratio_tachy = FFT_EGG.mean_power_ratio_tachy;

% %     logs = load(sprintf('/Users/au704655/Documents/EGG/Preproc/%.4d_EGGmeasures.mat', subj_name));
% %     log.SD_cycle_dur_norm = logs.log.SD_cycle_dur_norm;
% %     log.prop_norm_cycles = logs.log.prop_norm_cycles;
% %     log.mean_cycle_dur_norm = logs.log.mean_cycle_dur_norm;
% %     log.limits_3std_norm = logs.log.limits_3std_norm;
    
    %% Filtering
   % Filter the raw EGG from the selected channel around the dominant
   % frequency to extract the gastric rhythm using a finite impulse response
   % filter (Matlab FIR2), with a banwith of +/- 0.015 Hz of the peak
   % frequency.
   % Also compute phase of the gastric cycle and the amplitude envelope of the
   % filtered EGG, using the Hilbert method.
    
    % normogastria
    EGG_filtered_norm = compute_filter_EGG(EGG_raw, FFT_EGG.max_chan_norm, FFT_EGG.max_freq_norm);
    [figure_EGG_filtered_norm] = plot_EGG_visual_inspection(EGG_filtered_norm);
    
    % bradygastria
    if ~isnan(FFT_EGG.max_freq_brady)
        EGG_filtered_brady = compute_filter_EGG(EGG_raw, FFT_EGG.max_chan_brady, FFT_EGG.max_freq_brady);
        %[figure_EGG_filtered_brady] = plot_EGG_visual_inspection(EGG_filtered_brady);
    end
    
    % tachygastria
    if ~isnan(FFT_EGG.max_freq_tachy)
        EGG_filtered_tachy = compute_filter_EGG(EGG_raw, FFT_EGG.max_chan_tachy, FFT_EGG.max_freq_tachy);
        %[figure_EGG_filtered_tachy] = plot_EGG_visual_inspection(EGG_filtered_tachy);
    end
    
    % Show standard deviation of cycle duration - normogastria (0.033-0.066 Hz / 2-4 cpm)
    
    stds_cycle_durations = compute_std_cycle_duration(EGG_filtered_norm);
    log.SD_cycle_dur_norm = stds_cycle_durations;
    
    % Show proportion of normogastria (0.033-0.066 Hz / 2-4 cpm)
    
    [prop_norm, mean_cycle_dur_norm, limits_3std_norm] = show_prop_normogastria(EGG_filtered_norm, 0);
    log.prop_norm_cycles = prop_norm;
    log.mean_cycle_dur_norm = mean_cycle_dur_norm;
    log.limits_3std_norm = limits_3std_norm;
    
    %% Show standard deviation of cycle duration - bradygastria (0.02-0.03 Hz / 1–2 cpm) 
    if ~isnan(FFT_EGG.max_freq_brady)
        stds_cycle_durations = compute_std_cycle_duration(EGG_filtered_brady);
        log.SD_cycle_dur_brady = stds_cycle_durations;
        
        %% Show proportion of bradygastria (0.02-0.03 Hz / 1–2 cpm) 
        
        [prop_brady, mean_cycle_dur_brady, limits_3std_brady] = show_prop_bradygastria(EGG_filtered_brady, 0);
        log.prop_brady = prop_brady;
        log.mean_cycle_dur_brady = mean_cycle_dur_brady;
        log.limits_3std_brady = limits_3std_brady;
    end
    
    %% Show standard deviation of cycle duration - tachygastria (0.07-0.17 Hz / 4-10 cpm)  
    if ~isnan(FFT_EGG.max_freq_tachy)
        stds_cycle_durations = compute_std_cycle_duration(EGG_filtered_tachy);
        log.SD_cycle_dur_tachy = stds_cycle_durations;
        
        %% Show proportion of tachygastria (0.07-0.17 Hz / 4-10 cpm)  
        
        [prop_tachy, mean_cycle_dur_tachy, limits_3std_tachy] = show_prop_tachygastria(EGG_filtered_tachy, 0);
        log.prop_tachy = prop_tachy;
        log.mean_cycle_dur_tachy = mean_cycle_dur_tachy;
        log.limits_3std_tachy = limits_3std_tachy;
    end
    
    %% save all
    folderpath = '/Users/au704655/Documents/EGG/Preproc/';
    save(sprintf('%s%.4d_EGGmeasures.mat', folderpath, subj_name), 'log')
    clearvars -except subj_id subj 

end


%% Artifact detection

%close all;
%[art_def, figure_EGG_artifacts] = detect_EGG_artifacts(EGG_filtered);
