function [X1,Y1,Z1] = CCAprepData()

% prepare control STD or connectivity data, psych data, and nuisance vars for CCA

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
ImagingFile = 'controlSTD_difumo256_mriqc';  % control standard deviation BOLD activity (- difumo parcellated) 
BehFile =  'grand_surveyscores_summary.tsv'; % psych data 
ConfoundsFile = 'demographics.tsv';  % nuisance data location 

%% ------------------------------------------------
% Load Control STD data (or control resting connectivity)
% -------------------------------------------------

% Load csv of difumo parcellated control STD
PLV_filepath     = fullfile(data_dir, ImagingFile);
PLV_file      = readtable(PLV_filepath);

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

%%%%%%%%%%%%%% control analysis with resting fMRI connectivity %%%%%%%%%%%%
% dirImaging         	= '/Users/au704655/Documents/StomachBrain/Data/difumo256';
% subjectFCfiles      = dir(dirImaging);
% netMats             = [];
% 
% for thisFile = 5 : length(subjectFCfiles)  %!!! IMPORTANT - CHECK STARTING INDEX (5 is because hidden files are listed as the first 4) !!
%     % Load .npy matrices
%     subFilePath     = fullfile(dirImaging, subjectFCfiles(thisFile).name);
%     thisSubMat      = readNPY(subFilePath);
% 
%     % remove cerebralspinal fluid, white matter and cerebellum regions
%     thisSubMat(idx2rem,:) = [];
%     thisSubMat(:,idx2rem) = [];
%     
%     % Reshape to row vector
%     thisSubArray    = upperMatTri2Vector(thisSubMat);
%     
%     % Get subject ID and add to first column
%     thisSubID       = str2double(subFilePath(end-7:end-4));
%     thisSubArray    = [thisSubID, thisSubArray];
%     
%     % Add to multi-sub matrix
%     netMats = [netMats; thisSubArray];
%     
% end

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

%%%%%%%% control analysis with netMats/BOLD signal variability %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % load subIDs from gastricPLV analysis
usableSubs = load([data_dir,'CCA_input/subIDs_CCA_PsychScoresSubscales.mat']).subIDs; 
Y0                  = PLV_file(ismember(PLV_file(:,1),usableSubs),:); %netMats(ismember(netMats(:,1),usableSubs),:);
X0                  = Beh_file(ismember(Beh_file(:,1),usableSubs),:); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%% Save the input matrices
if saveOutput
    filename    = 'cca_inputs_difumo256_ControlSTD_PsychScoresSubscales'; %cca_inputs_difumo256_ControlfMRIrest_PsychScoresSubscales
    dirCCAinput    	= fullfile('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/',filename);
 
    %% for CCA/PLS toolbox
    X = Y1; % control STD
    Y = X1; % beh data
    C = Z1; % confounds
    save(dirCCAinput, 'X','Y','C')
end
