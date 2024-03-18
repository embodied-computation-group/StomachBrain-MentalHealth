function [prop_normogastria, mean_cycle_duration, limits_3std] = show_prop_normogastria(EGG_filtered, plot_fig)
% This function plots the histogram of cycle duration, with 
% dotted red lines marking the limits of normogastric range 
% (0.033-0.067 Hz or 2-4 cpm).
%
% Inputs
%     EGG_filtered  filtered EGG signal (output from 'compute_filter_EGG.m')
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

% specfify the range of normogastria in seconds
% 2-4 cpm = 15-30 seconds = 0.03-0.07 Hz
range_normogastria = [15 30];

% compute cycle lengths in seconds
edges_cycles_samples = find(diff(EGG_filtered.trial{1}(2,:))<-1);
edges_cycles_tmstp   = EGG_filtered.time{1}(edges_cycles_samples);
lengths_cycles       = diff(edges_cycles_tmstp);

% compute proportion of normogastria
ind_outside       = [find(lengths_cycles<range_normogastria(1)) find(lengths_cycles>range_normogastria(2))];
prop_normogastria = (length(lengths_cycles)-length(ind_outside))/length(lengths_cycles)*100;

mean_cycle_duration = round(mean(lengths_cycles), 1);
limits_3std = [mean(lengths_cycles)-3*std(lengths_cycles) mean(lengths_cycles)+3*std(lengths_cycles)];

if plot_fig == 1
    % plot distribution of cycle lengths
    figure('units','normalized','outerposition',[0 0 1 1]); set(gcf,'color','w');
    [N, X] = hist(lengths_cycles);
    bar(X,N,'facecolor',[0 0.4 0]);
    yl=ylim;
    hold on;
    h1 = plot([range_normogastria(1) range_normogastria(1)],yl, 'r');
    set(h1, 'LineStyle', '--', 'LineWidth', 2);
    hold on;
    h2 = plot([range_normogastria(2) range_normogastria(2)],yl, 'r');
    set(h2, 'LineStyle', '--', 'LineWidth', 2);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',24);
    title(['Cycle length distribution, Proportion normogastria=' num2str(round(prop_normogastria, 1)) '%'], 'FontSize', 30);
    xlabel('Seconds', 'FontSize', 30);
    l=legend(h1, 'range normogastria'); l.FontSize=25;
end

fprintf(['\nPercentage normogastria: ' num2str(prop_normogastria) '%\n']);
fprintf(['\nAverage cycle duration: ' num2str(mean_cycle_duration) ' seconds\n']);
fprintf(['Limits +/-3std: ' num2str(limits_3std(1)) ', ' num2str(limits_3std(2)) ' seconds\n']);

end
