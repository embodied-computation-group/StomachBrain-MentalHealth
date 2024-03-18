function [FFT_EGG] = compute_FFT_EGG_LB(EGG_raw, plot_fig)
% This function computes the EGG power spectrum for all channels and selects the channel
% with the strongest peak in the between 0.033 and 0.067 Hz.
% Note: Sometimes the peak might have to be selected manually.
%
% Inputs
%     EGG_raw         Fieldtrip structure with raw EGG data
%
% Outputs
%     FFT_EGG         data structure containing the power spectra, selected channel and peak frequency
%     figure_fft      figure showing the power spectrum for all channels
%
% When using this function in any published study, please cite:
% Wolpert, N, Rebollo, I, Tallon‐Baudry, C. Electrogastrography for psychophysiological
% research: Practical considerations, analysis pipeline, and normative data in a large
% sample. Psychophysiology. 2020; 57:e13599. https://doi.org/10.1111/psyp.13599
%
% This function was written in Matlab version R2017b.
%
% This function make use of the fieldtrip toolbox, version 20170315
% (see http://www.fieldtriptoolbox.org/).
% Reference:
% Robert Oostenveld, Pascal Fries, Eric Maris, and Jan-Mathijs Schoffelen.
% FieldTrip: Open Source Software for Advanced Analysis of MEG, EEG, and
% Invasive Electrophysiological Data. Computational Intelligence and
% Neuroscience, vol. 2011, Article ID 156869, 9 pages, 2011.
% doi:10.1155/2011/156869.
%
% Copyright (C) 2019, Laboratoire de Neurosciences Cognitives, Nicolai
% Wolpert, Ignacio Rebello & Catherine Tallon-Baudry
% Email: nicolaiwolpert@gmail.com
%
% DISCLAIMER:
% This code is provided without explicit or implicit guarantee, and without
% any form of technical support. The code is not intended to be used for
% clinical purposes. The functions are free to use and can be
% redistributed, modified and adapted, under the terms of the CC BY-NC-SA
% version of creative commons license (see
% <https://creativecommons.org/licenses/>).

fprintf('\n###############\nEstimating power spectra...\n\n')

% define the window inside which we search for the maximum peak
window = [0.033 0.067];

% cut data into trials by defining the length (in sec) of the data and the
% overlap between segments (ratio)
cfg = [];
cfg.length                  = 200;
cfg.overlap                 = 0.75;
EGG_trials                  = ft_redefinetrial(cfg, EGG_raw);

%% Filtering

cfg                 = [];
cfg.output          = 'pow';
cfg.channel         = 'all';
cfg.method          = 'mtmfft';
cfg.taper           = 'hann';
cfg.keeptrials      = 'no';
cfg.foilim          = [0 2];
cfg.pad             = 1000;
FFT_EGG     = ft_freqanalysis(cfg, EGG_trials);

%% normogastric FFT
% find indeces of normogastric frequencies
low_freq_indx             = find(FFT_EGG.freq > window(1), 1, 'first');
high_freq_indx            = find(FFT_EGG.freq < window(2), 1, 'last');

% find channel with highest peak in normogastric range
frequencies_normrange = FFT_EGG.freq(low_freq_indx:high_freq_indx);

% note the frequencies of the peaks for each channel
frequencies_peaks = nan(1, length(FFT_EGG.label));
% note the power of the peaks for each channel
power_peaks = nan(1, length(FFT_EGG.label));
for ichannel=1:length(FFT_EGG.label)

    % note power for the respective channel in the normogastric range
    power_normrange = FFT_EGG.powspctrm(ichannel, low_freq_indx:high_freq_indx);

    % find peaks (local maxima) for this channel in normogastric range
    [power_peak, indx_peak] = findpeaks(power_normrange);

    % find largest peak for this channel channel
    [~, idx_maxpeak] = max(power_peak);

    % note frequency and power of that peak
    if ~isempty(idx_maxpeak)
        frequencies_peaks(ichannel) = frequencies_normrange(indx_peak(idx_maxpeak));
        power_peaks(ichannel) = power_peak(idx_maxpeak);
    else
        frequencies_peaks(ichannel) = nan;
        power_peaks(ichannel) = nan;
    end

end

% find peak with maximum power
[max_pow_max_chan, max_chan_indx] = max(power_peaks);

% get name of channel with maximum power
max_chan = FFT_EGG.label(max_chan_indx);

% note corresponding frequency
max_freq = frequencies_peaks(max_chan_indx);

%% power of all gastria freqs (brady-norm-tachy) - for calculation of proportions of each 
window = [0.02 0.17];
% find indeces of normogastric frequencies
low_freq_indx             = find(FFT_EGG.freq > window(1), 1, 'first');
high_freq_indx            = find(FFT_EGG.freq < window(2), 1, 'last');
  
power_allgastriarange = FFT_EGG.powspctrm(ichannel, low_freq_indx:high_freq_indx);

%% store all parameters in data matrix - normogastria
FFT_EGG.max_chan_norm          = max_chan;
FFT_EGG.max_freq_norm          = max_freq;
FFT_EGG.max_chan_indx_norm     = max_chan_indx;
FFT_EGG.max_pow_max_chan_norm  = max_pow_max_chan;
%FFT_EGG.sum_power_norm = sum(power_normrange);
FFT_EGG.mean_power_norm = mean(power_normrange);
FFT_EGG.prop_power_norm = sum(power_normrange)/sum(power_allgastriarange);

if plot_fig == 1
    % show the power spectrum
    window = [0.033 0.067];
    figure_fft = figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,3,1)
    colors     = {[1 0 1];  [1 0 0]; [0 1 0];  [0 0 1]; [1 0.5 0]; [0.5 0 0]; [0 1 1]};   % 1. pink 2. red 3. green 4. dark blue 5. orange 6. dark red/ brown 7. light blue
    for nchan=1:length(FFT_EGG.label)
        hold on;
        % mark selected channel with a thicker line
        if nchan == max_chan_indx
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 2.5);
        else
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 1.5);
        end
    end
    hold on; plot(max_freq, max_pow_max_chan, '*', 'Color', colors{max_chan_indx}, 'MarkerSize', 15)
    text(max_freq,max_pow_max_chan,FFT_EGG.label{max_chan_indx}, 'Color', colors{max_chan_indx})
    xlim([0.01 0.09]); ylim([0 max_pow_max_chan+max_pow_max_chan*0.1]);
    shade = patch([window(1) window(2) window(2) window(1)], [0 0 max_pow_max_chan*1.5 max_pow_max_chan*1.5], [0.5 0.5 0.5]);
    set(shade, 'FaceColor', [0.5 0.5 0.5]);
    alpha(.05);
    ax = gca;
    ax.FontSize = 16;
    xlabel('Frequency (Hz)' , 'FontSize', 20);
    ylabel('Power', 'FontSize', 20);
    title(['Power spectrum - norm'], 'FontSize', 20);
    set(gcf,'units','normalized','outerposition',[0  0  1  1])
end

fprintf(['Channel selected: ' FFT_EGG.max_chan_norm{1} '\n']);
fprintf(['Peak frequency: ' num2str(FFT_EGG.max_freq_norm) '\n']);
fprintf(['Power: ' num2str(max_pow_max_chan) '\n']);

clearvars -except FFT_EGG plot_fig power_allgastriarange power_normrange

%% bradygastric FFT
% define the window inside which we search for the maximum peak
window = [0.02 0.03];
% find indeces of bradygastric frequencies
low_freq_indx             = find(FFT_EGG.freq > window(1), 1, 'first');
high_freq_indx            = find(FFT_EGG.freq < window(2), 1, 'last');

% find channel with highest peak in bradygastric range
frequencies_bradyrange = FFT_EGG.freq(low_freq_indx:high_freq_indx);

% note the frequencies of the peaks for each channel
frequencies_peaks = nan(1, length(FFT_EGG.label));
% note the power of the peaks for each channel
power_peaks = nan(1, length(FFT_EGG.label));
for ichannel=1:length(FFT_EGG.label)

    % note power for the respective channel in the bradygastric range
    power_bradyrange = FFT_EGG.powspctrm(ichannel, low_freq_indx:high_freq_indx);

    % find peaks (local maxima) for this channel in bradygastric range
    [power_peak, indx_peak] = findpeaks(power_bradyrange);

    % find largest peak for this channel channel
    [~, idx_maxpeak] = max(power_peak);

    % note frequency and power of that peak
    if ~isempty(idx_maxpeak)
        frequencies_peaks(ichannel) = frequencies_bradyrange(indx_peak(idx_maxpeak));
        power_peaks(ichannel) = power_peak(idx_maxpeak);
    else
        frequencies_peaks(ichannel) = nan;
        power_peaks(ichannel) = nan;
    end

end

% find peak with maximum power
[max_pow_max_chan, max_chan_indx] = max(power_peaks);

% get name of channel with maximum power
max_chan = FFT_EGG.label(max_chan_indx);

% note corresponding frequency
max_freq = frequencies_peaks(max_chan_indx);

% store all parameters in data matrix
FFT_EGG.max_chan_brady          = max_chan;
FFT_EGG.max_freq_brady          = max_freq;
FFT_EGG.max_chan_indx_brady     = max_chan_indx;
FFT_EGG.max_pow_max_chan_brady  = max_pow_max_chan;
%FFT_EGG.sum_power_brady = sum(power_bradyrange);
FFT_EGG.mean_power_brady = mean(power_bradyrange);
FFT_EGG.prop_power_brady = sum(power_bradyrange)/sum(power_allgastriarange);

if plot_fig == 1
    % show the power spectrum
    subplot(1,3,2)
    %figure_fft = figure('units','normalized','outerposition',[0 0 1 1]);
    colors     = {[1 0 1];  [1 0 0]; [0 1 0];  [0 0 1]; [1 0.5 0]; [0.5 0 0]; [0 1 1]};   % 1. pink 2. red 3. green 4. dark blue 5. orange 6. dark red/ brown 7. light blue
    for nchan=1:length(FFT_EGG.label)
        hold on;
        % mark selected channel with a thicker line
        if nchan == max_chan_indx
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 2.5);
        else
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 1.5);
        end
    end
    hold on; plot(max_freq, max_pow_max_chan, '*', 'Color', colors{max_chan_indx}, 'MarkerSize', 15)
    text(max_freq,max_pow_max_chan,FFT_EGG.label{max_chan_indx}, 'Color', colors{max_chan_indx})
    xlim([window(1)-0.01 window(2)+0.01]);
    if ~isempty(idx_maxpeak)
        ylim([0 max_pow_max_chan+max_pow_max_chan*0.1]);
    end
    ylims = ylim;
    shade = patch([window(1) window(2) window(2) window(1)], [0 0 ylims(2) ylims(2)], [0.5 0.5 0.5]);
    set(shade, 'FaceColor', [0.5 0.5 0.5]);
    alpha(.05);
    ax = gca;
    ax.FontSize = 16;
    xlabel('Frequency (Hz)' , 'FontSize', 20);
    ylabel('Power', 'FontSize', 20);
    title(['Power spectrum - brady'], 'FontSize', 20);
    set(gcf,'units','normalized','outerposition',[0  0  1  1])
end

fprintf(['Channel selected: ' FFT_EGG.max_chan_brady{1} '\n']);
fprintf(['Peak frequency: ' num2str(FFT_EGG.max_freq_brady) '\n']);
fprintf(['Power: ' num2str(max_pow_max_chan) '\n']);

clearvars -except FFT_EGG plot_fig power_allgastriarange power_normrange power_bradyrange

%% tachygastric FFT
% define the window inside which we search for the maximum peak
window = [0.07 0.17];
% find indeces of tachygastric frequencies
low_freq_indx             = find(FFT_EGG.freq > window(1), 1, 'first');
high_freq_indx            = find(FFT_EGG.freq < window(2), 1, 'last');

% find channel with highest peak in tachygastric range
frequencies_tachyrange = FFT_EGG.freq(low_freq_indx:high_freq_indx);

% note the frequencies of the peaks for each channel
frequencies_peaks = nan(1, length(FFT_EGG.label));
% note the power of the peaks for each channel
power_peaks = nan(1, length(FFT_EGG.label));
for ichannel=1:length(FFT_EGG.label)

    % note power for the respective channel in the tachygastric range
    power_tachyrange = FFT_EGG.powspctrm(ichannel, low_freq_indx:high_freq_indx);

    % find peaks (local maxima) for this channel in tachygastric range
    [power_peak, indx_peak] = findpeaks(power_tachyrange);

    % find largest peak for this channel channel
    [~, idx_maxpeak] = max(power_peak);

    % note frequency and power of that peak
    if ~isempty(idx_maxpeak)
        frequencies_peaks(ichannel) = frequencies_tachyrange(indx_peak(idx_maxpeak));
        power_peaks(ichannel) = power_peak(idx_maxpeak);
    else
        frequencies_peaks(ichannel) = nan;
        power_peaks(ichannel) = nan;
    end

end

% find peak with maximum power
[max_pow_max_chan, max_chan_indx] = max(power_peaks);

% get name of channel with maximum power
max_chan = FFT_EGG.label(max_chan_indx);

% note corresponding frequency
max_freq = frequencies_peaks(max_chan_indx);

% store all parameters in data matrix
FFT_EGG.max_chan_tachy          = max_chan;
FFT_EGG.max_freq_tachy          = max_freq;
FFT_EGG.max_chan_indx_tachy     = max_chan_indx;
FFT_EGG.max_pow_max_chan_tachy  = max_pow_max_chan;
%FFT_EGG.sum_power_tachy = sum(power_tachyrange);
FFT_EGG.mean_power_tachy = mean(power_tachyrange);
FFT_EGG.prop_power_tachy = sum(power_tachyrange)/sum(power_allgastriarange);

% mean power ratio for each gastria band
FFT_EGG.mean_power_ratio_norm = mean(power_normrange)/(mean(power_bradyrange)+mean(power_normrange)+mean(power_tachyrange));
FFT_EGG.mean_power_ratio_brady = mean(power_bradyrange)/(mean(power_bradyrange)+mean(power_normrange)+mean(power_tachyrange));
FFT_EGG.mean_power_ratio_tachy = mean(power_tachyrange)/(mean(power_bradyrange)+mean(power_normrange)+mean(power_tachyrange));


if plot_fig == 1
    subplot(1,3,3)
    % show the power spectrum
    %figure_fft = figure('units','normalized','outerposition',[0 0 1 1]);
    colors     = {[1 0 1];  [1 0 0]; [0 1 0];  [0 0 1]; [1 0.5 0]; [0.5 0 0]; [0 1 1]};   % 1. pink 2. red 3. green 4. dark blue 5. orange 6. dark red/ brown 7. light blue
    for nchan=1:length(FFT_EGG.label)
        hold on;
        % mark selected channel with a thicker line
        if nchan == max_chan_indx
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 2.5);
        else
            plot(FFT_EGG.freq, FFT_EGG.powspctrm(nchan, :), 'Color', colors{nchan}, 'LineWidth', 1.5);
        end
    end
    hold on; plot(max_freq, max_pow_max_chan, '*', 'Color', colors{max_chan_indx}, 'MarkerSize', 15)
    text(max_freq,max_pow_max_chan,FFT_EGG.label{max_chan_indx}, 'Color', colors{max_chan_indx})
    xlim([window(1)-0.1 window(2)+0.1]);
    if ~isempty(idx_maxpeak)
        ylim([0 max_pow_max_chan+max_pow_max_chan*0.1]);
    end
    ylims = ylim;
    shade = patch([window(1) window(2) window(2) window(1)], [0 0 ylims(2) ylims(2)*1.5], [0.5 0.5 0.5]);
    set(shade, 'FaceColor', [0.5 0.5 0.5]);
    alpha(.05);
    ax = gca;
    ax.FontSize = 16;
    xlabel('Frequency (Hz)' , 'FontSize', 20);
    ylabel('Power', 'FontSize', 20);
    title(['Power spectrum - tachy'], 'FontSize', 20);
    set(gcf,'units','normalized','outerposition',[0  0  1  1])
end

fprintf(['Channel selected: ' FFT_EGG.max_chan_tachy{1} '\n']);
fprintf(['Peak frequency: ' num2str(FFT_EGG.max_freq_tachy) '\n']);
fprintf(['Power: ' num2str(max_pow_max_chan) '\n']);

end

