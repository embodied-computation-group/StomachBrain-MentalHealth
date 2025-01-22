%% Test for gender or age effects

% load CCA with no gender or age as nuissance variable 
cfg = load('/Users/au704655/Documents/Body_wandering/Scripts/CCA/cca_pls_toolkit-master/_Project_StomachBrain_Revisions/framework/cca_pca_holdout5-0.40_subsamp5-0.40/cfg_1.mat');
res.dir.frwork = cfg.cfg.dir.frwork;
res.frwork.level = 1; % mode2plot
% get the correlation between the input variables and the latent variables/projections
res.gen.weight.type = 'correlation'; % for structure correlations/loadings & 'weight' for true model weights
res = res_defaults(res, 'load');

% for age make 1 best as highest correl
%res.frwork.split.best = 1;

% Get CCA variate/projections (1=stomachbrain, 2=mentalhealth)
P = plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.best, ...
    'training+test', '2d_group', 'gen.axes.FontSize', 20, ...
    'gen.legend.FontSize', 20, 'gen.legend.Location', 'NorthWest', ... 
    'proj.scatter.SizeData', 120, 'proj.scatter.MarkerEdgeColor', 'k', ...
    'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9; 0.9 0.3 0.3], ...
    'proj.xlabel', 'Stomach-Brain Coupling Variate', ...
    'proj.ylabel', 'Mental Health Variate', ...
    'proj.lsline', 'on');
    load([res.dir.frwork, sprintf('/res/level%d/model_1.mat', 1)]) % mode2plot
    title({sprintf('CCA Mode %d',1),sprintf('r = %.03f , p = %.03f', round(correl(res.frwork.split.best),3), round(res.stat.pval(res.frwork.split.best),3))},'fontsize',18)
    
    xlim([min(P(:,1))-0.02 max(P(:,1))+0.02]) % Stomach-Brain Coupling Variate
    ylim([min(P(:,2))-0.02 max(P(:,2))+0.02]) % Mental Health Variate

%% Gender 

% load demographics
CCAinput = load('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/cca_inputs_difumo256_gastricPLV_PsychScoresSubscales_regionsremoved_mriqc.mat'); 
Gender = CCAinput.C_nooutliers(:,3);  % male = -1 , female = 1

% t-test 
% Split P based on Gender
P_male = P(Gender == -1, :);   % Male group
P_female = P(Gender == 1, :);  % Female group

% Perform two-sample t-tests for both dimensions 
[h_sb, p_sb, ci_sb, stats_sb] = ttest2(P_male(:, 1), P_female(:, 1)) % stomach-brain sprintf('%.20f', p_sb)
[h_mh, p_mh, ci_mh, stats_mh] = ttest2(P_male(:, 2), P_female(:, 2)) % mental health sprintf('%.20f', p_mh)

%% Age 
CCAinput = load('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/cca_inputs_difumo256_gastricPLV_PsychScoresSubscales_regionsremoved_mriqc.mat');
Age = CCAinput.C_nooutliers(:,1);  

% Perform Pearson correlation between Age and P dimensions
[r_sb, p_sb] = corr(P(:, 1), Age, 'Type', 'Pearson') % stomach-brain
[r_mh, p_mh] = corr(P(:, 2), Age, 'Type', 'Pearson') % mental health


%% relationship with pca mental health scores 
PCA_psych = readmatrix('/Users/au704655/Documents/StomachBrain/CCA/scripts/Revisions/GenderAge/mentalhealth_PCA1.csv');
% load demographics
CCAinput = load('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/cca_inputs_difumo256_gastricPLV_PsychScoresSubscales_regionsremoved_mriqc.mat'); 
Gender = CCAinput.C_nooutliers(:,3);  % male = -1 , female = 1
Age = CCAinput.C_nooutliers(:,1);  

% t-test 
% Split PCA based on Gender
PCA_male = PCA_psych(Gender == -1, :);   % Male group
PCA_female = PCA_psych(Gender == 1, :);  % Female group
% Perform two-sample t-tests for both dimensions (X and Y)
[h_mh, p_mh, ci_mh, stats_mh] = ttest2(PCA_male(:, 1), PCA_female(:, 1))

% Perform Pearson correlation between Age and P dimension
[r_mh, p_mh] = corr(PCA_psych(:, 1), Age, 'Type', 'Pearson') % mental health

%% relationship with stomach-brain coupling (each parcel)
stomachbrain = CCAinput.X_nooutliers;

% Split based on Gender
sb_male = stomachbrain(Gender == -1, :);   % Male group
sb_female = stomachbrain(Gender == 1, :);  % Female group

for n = 1:size(stomachbrain,2)
% t-test 
% Perform two-sample t-tests for both dimensions (X and Y)
[h_sb(n), p_sb(n), ci_sb(n,:), stats] = ttest2(sb_male(:, n), sb_female(:, n));
tstat_sb(n) = stats.tstat;   % Store t-statistic separately

% Perform Pearson correlation between Age and P dimension
[r_sb(n), pcorr_sb(n)] = corr(stomachbrain(:, n), Age, 'Type', 'Pearson'); % mental health
end

% FDR correction for t-test p-values (Benjamini-Hochberg)
p_sb_fdr = mafdr(p_sb, 'BHFDR', true); % 'BHFDR' specifies the Benjamini-Hochberg procedure

% FDR correction corr p-values (Benjamini-Hochberg)
pcorr_sb_fdr = mafdr(pcorr_sb, 'BHFDR', true);

sum(pcorr_sb_fdr < 0.05)
sum(p_sb_fdr < 0.05)


