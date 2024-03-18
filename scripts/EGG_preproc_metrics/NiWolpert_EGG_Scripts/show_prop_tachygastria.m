function [prop_tachygastria, mean_cycle_duration, limits_3std] = show_prop_tachygastria(EGG_filtered, plot_fig)
% This function plots the histogram of cycle duration, with 
% dotted red lines marking the limits of bradygastric range 
% (0.07-0.16 Hz / 4.00–9.66 cpm).
%
% Inputs
%     EGG_filtered  filtered EGG signal (output from 'compute_filter_EGG.m')
 
% specfify the range of bradygastria in seconds
% 4-10 cpm = 6-15 seconds = 0.07-0.17 Hz
range_tachygastria = [6 15];

% compute cycle lengths in seconds
edges_cycles_samples = find(diff(EGG_filtered.trial{1}(2,:))<-1);
edges_cycles_tmstp   = EGG_filtered.time{1}(edges_cycles_samples);
lengths_cycles       = diff(edges_cycles_tmstp);

% compute proportion of normogastria
ind_outside       = [find(lengths_cycles<range_tachygastria(1)) find(lengths_cycles>range_tachygastria(2))];
prop_tachygastria = (length(lengths_cycles)-length(ind_outside))/length(lengths_cycles)*100;

mean_cycle_duration = round(mean(lengths_cycles), 1);
limits_3std = [mean(lengths_cycles)-3*std(lengths_cycles) mean(lengths_cycles)+3*std(lengths_cycles)];

if plot_fig == 1
    % plot distribution of cycle lengths
    figure('units','normalized','outerposition',[0 0 1 1]); set(gcf,'color','w');
    [N, X] = hist(lengths_cycles);
    bar(X,N,'facecolor',[0 0.4 0]);
    yl=ylim;
    hold on;
    h1 = plot([range_tachygastria(1) range_tachygastria(1)],yl, 'r');
    set(h1, 'LineStyle', '--', 'LineWidth', 2);
    hold on;
    h2 = plot([range_tachygastria(2) range_tachygastria(2)],yl, 'r');
    set(h2, 'LineStyle', '--', 'LineWidth', 2);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',24);
    title(['Cycle length distribution, Proportion tachygastria=' num2str(round(prop_tachygastria, 1)) '%'], 'FontSize', 30);
    xlabel('Seconds', 'FontSize', 30);
    l=legend(h1, 'range tachygastria'); l.FontSize=25;
end

fprintf(['\nPercentage tachygastria: ' num2str(prop_tachygastria) '%\n']);
fprintf(['\nAverage cycle duration: ' num2str(mean_cycle_duration) ' seconds\n']);
fprintf(['Limits +/-3std: ' num2str(limits_3std(1)) ', ' num2str(limits_3std(2)) ' seconds\n']);

end
