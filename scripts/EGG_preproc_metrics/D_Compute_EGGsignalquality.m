
%% list EGG fft files & EGG data log
clear all
fft_filepath = '/home/leah/Git/StomachBrain-MentalHealth/data/EGGpreproc_metrics/Data_Preproc/';
files = dir(fullfile(fft_filepath, '*fft.mat'));
EGG_log = readtable('/home/leah/Git/StomachBrain-MentalHealth/data/EGGpreproc_metrics/EGGmeasures.csv');

%% Make 'Excellent' gastric peak template
Excellent_subs = [500, 520, 224, 228, 233, 240, 204, 110, 52, 27];
for sub = 1:length(Excellent_subs)
    fft = load(fullfile(fft_filepath, sprintf('%04d_EGGfft.mat', Excellent_subs(sub)))); % load fft
    bestchan = table2array(EGG_log(find(EGG_log.SubID == Excellent_subs(sub)), 'BestChannel')); % find best EGG channel
    peak_freq = table2array(EGG_log(find(EGG_log.SubID == Excellent_subs(sub)), 'PeakFreq')); % peak gastric freq
    
    % z-score around peak freq for each subject (so gastric peaks are aligned across subjects)     
    startIndex = find(fft.frequencyWelch.freq == peak_freq) - 20; 
    endIndex = find(fft.frequencyWelch.freq == peak_freq) + 20; 
    % Extract window around the peak
    TEMPLATE_fft_Window = fft.frequencyWelch.powspctrm(bestchan, startIndex:endIndex);
    % Z-score this window
    TEMPLATE_fft_WindowZscored(sub,:) = (TEMPLATE_fft_Window - mean(TEMPLATE_fft_Window)) / std(TEMPLATE_fft_Window);
    %figure; plot(fft.frequencyWelch.freq(startIndex:endIndex), TEMPLATE_fft_WindowZscored(sub,:), '-o','lineWidth',3); xlim([min(fft.frequencyWelch.freq(startIndex:endIndex)), max(fft.frequencyWelch.freq(startIndex:endIndex))]);
end
figure; plot(fft.frequencyWelch.freq(startIndex:endIndex), TEMPLATE_fft_WindowZscored, '-o','lineWidth',3);  
% make 'excellent' fft average (template)
EXCELLENT_TEMPLATE_fft = mean(TEMPLATE_fft_WindowZscored, 1);
figure; plot(fft.frequencyWelch.freq(startIndex:endIndex), EXCELLENT_TEMPLATE_fft, '-o','lineWidth',3);  

%% load fft each subject and compare to 'Excellent' template
all_fft_WindowZscored = [];
for n = 1:length(files)
    fft = load(fullfile(fft_filepath, files(n).name)); % load fft
    SubID(n) = str2double(files(n).name(1:4)); % subject ID
    bestchan = table2array(EGG_log(find(EGG_log.SubID == SubID(n)), 'BestChannel')); % find best EGG channel
    peak_freq = table2array(EGG_log(find(EGG_log.SubID == SubID(n)), 'PeakFreq')); % peak gastric freq

    % z-score around peak freq for each subject (so gastric peaks are aligned across subjects)     
    startIndex = find(fft.frequencyWelch.freq == peak_freq) - 20; % If ensure startIndex is not less than 1 : max(1, find(fft.frequencyWelch.freq == peak_freq) - 20);
    endIndex = find(fft.frequencyWelch.freq == peak_freq) + 20; % If ensure endIndex does not exceed data length : min(length(fft.frequencyWelch.powspctrm), find(fft.frequencyWelch.freq == peak_freq) + 20)
    % Extract window around the peak
    fft_Window = fft.frequencyWelch.powspctrm(bestchan, startIndex:endIndex);
    % Z-score this window
    fft_WindowZscored = (fft_Window - mean(fft_Window)) / std(fft_Window);
    %figure; plot(fft.frequencyWelch.freq(startIndex:endIndex), fft_WindowZscored, '-o','lineWidth',3); xlim([min(fft.frequencyWelch.freq(startIndex:endIndex)), max(fft.frequencyWelch.freq(startIndex:endIndex))]);
    
    % Store the z-scored data for plotting later
    all_fft_WindowZscored = [all_fft_WindowZscored; fft_WindowZscored];

    %% compare to excellent template for signal2noise metric 
    
    % pearsons correlation 
    corrcoeffs_p(n) = corr(EXCELLENT_TEMPLATE_fft', fft_WindowZscored');

    % cosine similarity
    cosSim(n) = dot(abs(fft_WindowZscored), abs(EXCELLENT_TEMPLATE_fft)) / (norm(abs(fft_WindowZscored)) * norm(abs(EXCELLENT_TEMPLATE_fft)));

end

%% 265 subjects rated 'excellent' (184) or 'good' (81)
Good_subs = table2array(EGG_log(find(EGG_log.ratings >= 0.91), 'SubID'));
Bad_subs = table2array(EGG_log(find(EGG_log.ratings == 0), 'SubID'));


% %% cosine and pearson stats (for good vs bad rated subjects)
% Goodsubs_cosSim = cosSim(find(ismember(SubID, Good_subs)));
% Badsubs_cosSim = cosSim(find(ismember(SubID, Bad_subs)));
% [p, h, stats] = ranksum(Goodsubs_cosSim, Badsubs_cosSim);
% U = stats.ranksum;  % The Mann-Whitney U statistic
% % Rank-biserial correlation calculation (simplified estimation)
% m = numel(Goodsubs_cosSim) * numel(Badsubs_cosSim) / 2;
% rank_biserial = (U - m) / m;
% fprintf('U = %.3f, p = %.3f. ', U, p);
% fprintf('The effect size, measured using rank-biserial correlation, was %.3f \n', rank_biserial);
% fprintf('Rated good: Median = %.3f, Range = %.3f, Rated bad: Median = %.3f, Range = %.3f \n', median(Goodsubs_cosSim), range(Goodsubs_cosSim), median(Badsubs_cosSim), range(Badsubs_cosSim));
% 
% Goodsubs_pearson = corrcoeffs_p(find(ismember(SubID, Good_subs)));
% Badsubs_pearson = corrcoeffs_p(find(ismember(SubID, Bad_subs)));
% [p, h, stats] = ranksum(Goodsubs_pearson, Badsubs_pearson);
% U = stats.ranksum;  % The Mann-Whitney U statistic
% % Rank-biserial correlation calculation (simplified estimation)
% m = numel(Goodsubs_pearson) * numel(Badsubs_pearson) / 2;
% rank_biserial = (U - m) / m;
% fprintf('U = %.3f, p = %.3f. ', U, p);
% fprintf('The effect size, measured using rank-biserial correlation, was %.3f \n', rank_biserial);
% fprintf('Rated good: Median = %.3f, Range = %.3f, Rated bad: Median = %.3f, Range = %.3f \n', median(Goodsubs_pearson), range(Goodsubs_pearson), median(Badsubs_pearson), range(Badsubs_pearson));
% 
% %% confirm psych scores are not different with rejected and included EGG
% Psych = readtable('//home/leah/Git/StomachBrain-MentalHealth/data/psych_scores/grand_surveyscores_summary.tsv', 'TreatAsEmpty',{'NA'}, 'Delimiter', '\t', 'FileType', 'text'); % load all psych scores 
% Psych = table2array(Psych(:,{'id', 'aq10', 'asrs_a_sum', 'asrs_b_sum', 'iri_FS', 'iri_EC', 'iri_PT', 'iri_PD', 'isi', 'maia_notice', 'maia_ndistract', 'maia_nworry', 'maia_attnReg', 'maia_EmoAware', 'maia_SelfRef', 'maia_listen', 'maia_trust' , 'mdi', 'mfi_physical_fatigue', 'mfi_general_fatigue', 'mfi_reduced_activity', 'mfi_reduced_motivation', 'mfi_mental_fatigue', 'mpsss_so', 'mpsss_fam', 'mpsss_friends', 'phq9', 'phq15', 'pss', 'sias', 'stai_trait', 'wemwbs', 'who', 'whoqol_quality_life', 'whoqol_physical', 'whoqol_phychological', 'whoqol_social_relationships', 'whoqol_enviroment'})); 
% Psych = Psych((find(ismember(Psych(:,1), SubID))),:);
% % PCA on Psych scores of subjects with EGG
% [coeff, score, latent, tsquared, explained] = pca(Psych(:,2:end));
% % 
% Goodsubs_psych = score(find(ismember(SubID, Good_subs)));
% Badsubs_psych = score(find(ismember(SubID, Bad_subs)));
% [p, h, stats] = ranksum(Goodsubs_psych, Badsubs_psych);
% U = stats.ranksum;  % The Mann-Whitney U statistic
% % Rank-biserial correlation calculation (simplified estimation)
% m = numel(Goodsubs_psych) * numel(Badsubs_psych) / 2;
% rank_biserial = (U - m) / m;
% fprintf('U = %.3f, p = %.3f. ', U, p);
% fprintf('The effect size, measured using rank-biserial correlation, was %.3f \n', rank_biserial);
% fprintf('Rated good: Median = %.3f, Range = %.3f, Rated bad: Median = %.3f, Range = %.3f \n', nanmedian(Goodsubs_psych), range(Goodsubs_psych), nanmedian(Badsubs_psych), range(Badsubs_psych));



%% figures
% Included subjects 
for n = 1:length(Good_subs)
    Good_idx(n) = find(SubID == Good_subs(n));
end
% Excluded subjects 
for n = 1:length(Bad_subs)
    Bad_idx(n) = find(SubID == Bad_subs(n));
end

% template fig (of top 10)
figure;
cmap = colormap('magma'); % parula
cmap = interp1(1:size(cmap, 1), cmap, linspace(1, size(cmap, 1), size(TEMPLATE_fft_WindowZscored, 1)), 'linear');
randomIndices = randperm(length(cmap));
count = 1;
for n = 1:size(TEMPLATE_fft_WindowZscored, 1)
    plot(fft.frequencyWelch.freq(plot_startIndex:plot_endIndex), TEMPLATE_fft_WindowZscored(n,plot_startIndex:plot_endIndex), '-','lineWidth',2, 'Color', cmap(randomIndices(count), :)); 
    count = count +1;
    hold on;
end
box off;
xlabel('Frequency (Hz)', 'FontSize', 14); 
ylabel('Amplitude (z-score)', 'FontSize', 14); 
title('Excellent Template Subjects', 'FontSize', 16); % Provide a meaningful title
set(gca, 'FontSize', 14); % Sets the font size of the tick labels
%saveas(gcf, 'Git/StomachBrain-MentalHealth/figures/methods/EGG_preproc/EGGfft_ExcellentTemplate.png');

% EGG quality metric plots

% cross-correlation
figure;
histogram(maxCorr(Good_idx), 'FaceColor', 'blue', 'FaceAlpha', 0.5); hold on;  
histogram(maxCorr(Bad_idx), 'FaceColor', 'red', 'FaceAlpha', 0.5); 
legend('Included', 'Excluded', 'Location', 'northwest'); 
box off;
xlabel('Cross-Correlation', 'FontSize', 14); 
ylabel('Participants', 'FontSize', 14); 
title('Cross-Correlation', 'FontSize', 16); % Provide a meaningful title
set(gca, 'FontSize', 14); 
saveas(gcf, 'Git/StomachBrain-MentalHealth/figures/methods/EGG_preproc/Cross-Correlation.png');

% pearsons correlation 
figure;
histogram(corrcoeffs_p(Good_idx), 'FaceColor', 'blue', 'FaceAlpha', 0.5); hold on;  
histogram(corrcoeffs_p(Bad_idx), 'FaceColor', 'red', 'FaceAlpha', 0.5); 
legend('Included', 'Excluded', 'Location', 'northwest'); 
box off;
xlabel('Pearson Correlation', 'FontSize', 14); 
ylabel('Participants', 'FontSize', 14); 
title('Pearson Correlation', 'FontSize', 16); % Provide a meaningful title
set(gca, 'FontSize', 14); 
saveas(gcf, 'Git/StomachBrain-MentalHealth/figures/methods/EGG_preproc/PearsonCorrelation.png');
