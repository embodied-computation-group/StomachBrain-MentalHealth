
%% CCA using CCA/PLS Toolkit %%
tic
clear all
set_path;

% add dependencies
set_path('PALM'); 

% X = stomach-brain coupling data %
% Y = psych data 

%% set cfg
% Project folder
cfg.dir.project = '/home/leah/Git/connectivity_tools/toolboxes/matlab/cca_pls_toolkit-master/_Project_StomachBrain/'; 

% Machine settings
cfg.machine.name = 'cca'; 
cfg.machine.param.name = {'PCAx', 'PCAy'}; % set pca-cca
cfg.machine.param.crit = 'correl'; % criterion to select the best hyperparameter (num pca components - based on test correlation in inner data splits) 
% cfg.machine.param.nPCAy = 1; % no PCA for Y (beh data) so set to 1
cfg.machine.metric =  {'trcorrel', 'correl', 'exvarx', 'exvary', 'trexvarx', 'trexvary', 'simwx', 'simwy'}; %'correl'=out-of-sample correlation, 'trcorrel'=in-sample correlation + store extra metrics for plotting hyperparameter surface

% Framework settings
cfg.frwork.name = 'holdout'; % framework details
cfg.frwork.split.nout = 5; % number of outer data splits (for cross-validation)
cfg.frwork.split.nin = 5; % number of inner data splits (for hyperparameter selection - number of pca components for X)
cfg.frwork.split.propout = 0.4; % proportion of data in outer split
cfg.frwork.split.propin = 0.4; % proportion of data in inner split

% Deflation settings
cfg.defl.name = 'generalized'; % ensures pairs of weights (cca modes?) are orthoganol

% Environment settings
cfg.env.comp = 'cluster'; %'local'

% Statistical inference settings
cfg.stat.nperm = 1000;
cfg.stat.crit = 'correl'; % criterion for statistic inference within each split(out-of-sample correlation)

% remove confounds from X & Y
cfg.data.conf = true; % confounds

% Update cfg with defaults
cfg = cfg_defaults(cfg);


%% Run analysis
main(cfg);

% Clean up analysis files to save disc space
% cleanup_files(cfg); % should run this line locally (not on the cluster - after running this script)

toc


