function [prop_bradygastria, mean_cycle_duration, limits_3std] = show_prop_bradygastria(EGG_filtered, plot_fig)
% This function plots the histogram of cycle duration, with 
% dotted red lines marking the limits of bradygastric range 
% (0.01-0.04 Hz / 0.33–2.33 cpm).
%
% Inputs
%     EGG_filtered  filtered EGG signal (output from 'compute_filter_EGG.m')
 
% specfify the range of bradygastria in seconds
% 1–2 cpm = 30-60 seconds = 0.02-0.03 Hz
range_bradygastria = [30 60];

% compute cycle lengths in seconds
edges_cycles_samples = find(diff(EGG_filtered.trial{1}(2,:))<-1);
edges_cycles_tmstp   = EGG_filtered.time{1}(edges_cycles_samples);
lengths_cycles       = diff(edges_cycles_tmstp);

% compute proportion of normogastria
ind_outside       = [find(lengths_cycles<range_bradygastria(1)) find(lengths_cycles>range_bradygastria(2))];
prop_bradygastria = (length(lengths_cycles)-length(ind_outside))/length(lengths_cycles)*100;

mean_cycle_duration = round(mean(lengths_cycles), 1);
limits_3std = [mean(lengths_cycles)-3*std(lengths_cycles) mean(lengths_cycles)+3*std(lengths_cycles)];

if plot_fig == 1
    % plot distribution of cycle lengths
    figure('units','normalized','outerposition',[0 0 1 1]); set(gcf,'color','w');
    [N, X] = hist(lengths_cycles);
    bar(X,N,'facecolor',[0 0.4 0]);
    yl=ylim;
    hold on;
    h1 = plot([range_bradygastria(1) range_bradygastria(1)],yl, 'r');
    set(h1, 'LineStyle', '--', 'LineWidth', 2);
    hold on;
    h2 = plot([range_bradygastria(2) range_bradygastria(2)],yl, 'r');
    set(h2, 'LineStyle', '--', 'LineWidth', 2);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',24);
    title(['Cycle length distribution, Proportion bradygastria=' num2str(round(prop_bradygastria, 1)) '%'], 'FontSize', 30);
    xlabel('Seconds', 'FontSize', 30);
    l=legend(h1, 'range bradygastria'); l.FontSize=25;
end

fprintf(['\nPercentage bradygastria: ' num2str(prop_bradygastria) '%\n']);
fprintf(['\nAverage cycle duration: ' num2str(mean_cycle_duration) ' seconds\n']);
fprintf(['Limits +/-3std: ' num2str(limits_3std(1)) ', ' num2str(limits_3std(2)) ' seconds\n']);

end
