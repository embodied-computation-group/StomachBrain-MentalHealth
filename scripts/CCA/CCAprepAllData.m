function [X1,Y1,Z1] = CCAprepData()

% prepare gastric PLV data, psych data, and nuisance vars for CCA

%   Outputs
% X1  sub variables of interest 
% Y1  gastric PLV-chance
% Z1  confounds 
clear all
addpath(genpath("/Users/au704655/Documents/Body_wandering/Scripts/CCA/supporting_packages/"))

%% Key flags 
saveOutput          = 1;

%% Data directories
% imaging data location
data_dir = '/Users/au704655/Documents/StomachBrain/CCA/data/';
ImagingFile = 'diff_PLV_difumo256_mriqc.csv';  % gastric-brain coupling data (phase locking value - difumo parcellated) 
BehFile =  'grand_surveyscores_summary.tsv'; % psych data 
ConfoundsFile = 'demographics.tsv';  % nuisance data location 

%% ------------------------------------------------
% Load gastric PLV data 
% -------------------------------------------------

% Load csv of difumo parcellated PLV minus chancePLV
PLV_filepath     = fullfile(data_dir, ImagingFile);
PLV_file      = readtable(PLV_filepath);
% remove first redundant row & move sub-ids to beginning
PLV_file(1,:) = [];
PLV_file = movevars(PLV_file,'Var257','Before','Var1');

% exclude cerebralspinal fluid, ventricle & white matter difumo regions
idx2rem = [];
difumolabels = readtable(fullfile(data_dir, 'difumo256_mnicoords_AtlasLabels.csv'));
for n = 1 : size(difumolabels,1)
    if contains(difumolabels{n,'Difumo_names'}, 'fluid','IgnoreCase', true) || contains(difumolabels{n,'Difumo_names'}, 'ventricle', 'IgnoreCase', true) || contains(difumolabels{n,'Harvard_OxfordSubcorticalStructuralAtlas'}, 'White Matter', 'IgnoreCase', true) 
        idx2rem(end+1) = n;
    end
end
% remove cerebralspinal fluid, ventricle & white matter regions from PLV_file
PLV_file(:,idx2rem+1) = []; % + 1 due to sub_ID col

% convert to double
PLV_file       = table2array(PLV_file);

% remove outlier subjects - PLV 
PLV_median_regions = median(PLV_file(:,2:end), 2); % median across all regions per subject
IQR = prctile(PLV_median_regions, 75) - prctile(PLV_median_regions, 25);  % Calculate the interquartile range
outliers_idx = find(PLV_median_regions < (prctile(PLV_median_regions, 25) - 1.5 * IQR) | PLV_median_regions > (prctile(PLV_median_regions, 75) + 1.5 * IQR)); 
PLV_file(outliers_idx,:) = [];

%% -----------------------------------------------
% Load Psych subject-level data 
% ------------------------------------------------
Beh_file = readtable(fullfile(data_dir, BehFile), 'TreatAsEmpty',{'NA'}, 'FileType','text', 'Delimiter','\t'); 
Beh_file = Beh_file(:,{'id', 'aq10', 'asrs_a_sum', 'asrs_b_sum', 'iri_FS', 'iri_EC', 'iri_PT', 'iri_PD', 'isi', 'maia_notice', 'maia_ndistract', 'maia_nworry', 'maia_attnReg', 'maia_EmoAware', 'maia_SelfRef', 'maia_listen', 'maia_trust' , 'mdi', 'mfi_physical_fatigue', 'mfi_general_fatigue', 'mfi_reduced_activity', 'mfi_reduced_motivation', 'mfi_mental_fatigue', 'mpsss_so', 'mpsss_fam', 'mpsss_friends', 'phq9', 'phq15', 'pss', 'sias', 'stai_trait', 'wemwbs', 'who', 'whoqol_quality_life', 'whoqol_physical', 'whoqol_phychological', 'whoqol_social_relationships', 'whoqol_enviroment'}); 

% convert to double
Beh_file       = table2array(Beh_file);

% remove subjects with NaN's
Beh_file(any(isnan(Beh_file), 2), :) = [];

%% Clean up input matrices

% Remove subjects who don't have both data types
usableSubs          = intersect(PLV_file(:,1),Beh_file(:,1));

% Get only usable subjects from netMats and task 
Y0                  = PLV_file(ismember(PLV_file(:,1),usableSubs),:);
X0                  = Beh_file(ismember(Beh_file(:,1),usableSubs),:); 

Y0 = sortrows(Y0,1);
X0 = sortrows(X0,1);

%% ------------------------------------------------
% Load CONFOUNDS
% -------------------------------------------------
Confounds_file   	= readtable(fullfile(data_dir, ConfoundsFile), 'TreatAsEmpty',{'NA'},'FileType','text', 'Delimiter','\t');

% extract confound variables of interest
ID              = cellfun(@(x){x(5:8)}, Confounds_file.participant_id);
gender          = Confounds_file.gender;              
age             = Confounds_file.age;
weight          = Confounds_file.weight;
height          = Confounds_file.height;

% calculate bmi (height in cm, weight in kilos)(BMI = kg/m2)
bmi = (weight./(height.*height))*10000;

% define vmp1/2 session for confound array
session = ones(length(ID),1);
session(str2num(cell2mat(ID)) < 163) = -1;

Confounds_file 	= horzcat(str2num(cell2mat(ID)),age,bmi,gender,session);
% remove gender = 3 (other)
Confounds_file(find(Confounds_file(:,4) == 3),:) = []; 

% make gender 1 & -1
Confounds_file(find(Confounds_file(:,4) == 2),4) = -1; % male = -1 , female = 1

% match subjects
Confounds_file  = sortrows(Confounds_file,1);
Z0              = Confounds_file(ismember(Confounds_file(:,1),usableSubs),:);  

% Find subjects without phenotype data and remove from X & Y
[row, col] = find(isnan(Z0)); 
missingPhenoSubs    = Z0(row,1);
X0                  = X0(~ismember(X0(:,1),missingPhenoSubs),:);
Y0                  = Y0(~ismember(Y0(:,1),missingPhenoSubs),:);
Z0(row,:) = [];

%% Remove subject IDs
X1      = X0(:,2:end);
Y1      = Y0(:,2:end);
Z1      = Z0(:,2:end);

%% check for/remove outliers in beh vars
threshold = 3;
outliers = [];

for n = 1:size(X1, 2)
    z = abs((X1(:,n) - mean(X1(:,n))) / std(X1(:,n)));
    outlier = find(z > threshold);
    for nn = 1:length(outlier)
        outliers(end+1) = outlier(nn);
    end
end
if ~isempty(outliers)
    X1_nooutliers = X1;
    Y1_nooutliers = Y1;
    Z1_nooutliers = Z1;
    X1_nooutliers(outliers, :) = [];
    Y1_nooutliers(outliers, :) = [];
    Z1_nooutliers(outliers, :) = [];
end

%% Save the input matrices
if saveOutput
    filename    = 'cca_inputs_difumo256_gastricPLV_PsychScoresSubscales';
    dirCCAinput    	= fullfile('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/',filename);
 
    %% for CCA/PLS toolbox
    X = Y1; % gastric PLV data
    Y = X1; % beh data
    C = Z1; % confounds
    if ~isempty(outliers)
        X_nooutliers = Y1_nooutliers; % gastric PLV data
        Y_nooutliers = X1_nooutliers; % psych data
        C_nooutliers = Z1_nooutliers; % confounds
        save(dirCCAinput, 'X','Y','C','X_nooutliers','Y_nooutliers','C_nooutliers')
    else
        save(dirCCAinput, 'X','Y','C')
    end
end
