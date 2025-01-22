%% Check CCA MentalHealth & StomachBrain variate same across electrode choice for each EGG recording montage 

% load EGG montage details
EGGdetails = readtable('/Users/au704655/Documents/StomachBrain/CCA/data/EGG_MentalHealth_Intero_MindWand_Lifestyle.csv');
% select CCA subjects only
load('/Users/au704655/Documents/StomachBrain/CCA/data/CCA_input/subIDs_CCA_PsychScoresSubscales.mat')
EGGdetails = EGGdetails(ismember(EGGdetails.SubID, subIDs), :);

% load CCA variate (mental health variate and stomach-brain coupling variate)
CCAvariate = load('/Users/au704655/Documents/StomachBrain/CCA/data/CCAvariates/CCAvariate_Psych/CCAvariate_StomachBrain_PsychScoresSubscales_CCA1.mat').P;
% order = 'BrainStomach.CCA', 'Psych.CCA'

% for each multi-channel montage (3 or 6 bipolar channels) % table2array(unique(EGGdetails(:,'nChannels')))
for n = [3, 6]

    % select subjects with same EGG recording montage
    EGGdetails_selected = EGGdetails(ismember(EGGdetails.nChannels, n), :);
    
    % number of selected EGG channel options
    unique_channels = unique(EGGdetails_selected.BestChannel); % Get unique channels
    EGGsubs = cell(size(unique_channels)); % Pre-allocate cell array
    
    % select CCA variate groups based on selected EGG channel
    for idx = 1:length(unique_channels)
        nn = unique_channels(idx); % Get the unique value of BestChannel
        EGGsubs{idx} = EGGdetails_selected(ismember(EGGdetails_selected.BestChannel, nn), {'SubID'});
        group_idx{idx} = find(ismember(subIDs, table2array(EGGsubs{idx})));
        StomachBrain_groups{idx} = CCAvariate(group_idx{idx},1);
        MentalHealth_groups{idx} = CCAvariate(group_idx{idx},2);
    end
    
    % Perform one-way ANOVA - StomachBrain CCA variate (with diff selected EGG channel for each montage)
    grouped_data = cell2mat(StomachBrain_groups'); % Convert to matrix form for ANOVA
    group_labels = cell2mat(arrayfun(@(x) repmat(x, length(StomachBrain_groups{x}), 1), 1:length(StomachBrain_groups), 'UniformOutput', false)');

    [p, tbl, stats] = anova1(grouped_data, group_labels);

    % Calculate eta-squared (η²)
    SS_between = tbl{2, 2}; % Sum of squares for 'Groups'
    SS_total = tbl{4, 2};   % Sum of squares for 'Total'
    n2 = SS_between / SS_total

    % Perform one-way ANOVA - MentalHealth CCA variate (with diff selected EGG channel for each montage)
    grouped_data = cell2mat(MentalHealth_groups'); % Convert to matrix form for ANOVA
    group_labels = cell2mat(arrayfun(@(x) repmat(x, length(MentalHealth_groups{x}), 1), 1:length(MentalHealth_groups), 'UniformOutput', false)');

    [p, tbl, stats] = anova1(grouped_data, group_labels);

    % Calculate eta-squared (η²)
    SS_between = tbl{2, 2}; % Sum of squares for 'Groups'
    SS_total = tbl{4, 2};   % Sum of squares for 'Total'
    n2 = SS_between / SS_total

    clear EGGsubs group_idx StomachBrain_groups MentalHealth_groups grouped_data group_labels
end

%% Also check across EGG recording montages
% for each montage (1, 3 or 6 bipolar channels) % table2array(unique(EGGdetails(:,'nChannels')))
for n = [1, 3, 6]

    % select subjects with same EGG recording montage
    %EGGdetails_selected = EGGdetails(ismember(EGGdetails.nChannels, n), :);
    
    % number of selected EGG channel options
    unique_montage = unique(EGGdetails.nChannels); % Get unique channels
    EGGsubs = cell(size(unique_montage)); % Pre-allocate cell array
    
    % select CCA variate groups based on EGG montage
    for idx = 1:length(unique_montage)
        nn = unique_montage(idx); % Get the unique value of BestChannel
        EGGsubs{idx} = EGGdetails(ismember(EGGdetails.nChannels, nn), {'SubID'});
        group_idx{idx} = find(ismember(subIDs, table2array(EGGsubs{idx})));
        StomachBrain_groups{idx} = CCAvariate(group_idx{idx},1);
        MentalHealth_groups{idx} = CCAvariate(group_idx{idx},2);
    end
end
    
    % Perform one-way ANOVA - StomachBrain CCA variate (with diff selected EGG channel for each montage)
    grouped_data = cell2mat(StomachBrain_groups'); % Convert to matrix form for ANOVA
    group_labels = cell2mat(arrayfun(@(x) repmat(x, length(StomachBrain_groups{x}), 1), 1:length(StomachBrain_groups), 'UniformOutput', false)');

    [p, tbl, stats] = anova1(grouped_data, group_labels);

    % Calculate eta-squared (η²)
    SS_between = tbl{2, 2}; % Sum of squares for 'Groups'
    SS_total = tbl{4, 2};   % Sum of squares for 'Total'
    n2 = SS_between / SS_total


%     % Perform one-way ANOVA - MentalHealth CCA variate (with diff selected EGG channel for each montage)
%     grouped_data = cell2mat(MentalHealth_groups'); % Convert to matrix form for ANOVA
%     group_labels = cell2mat(arrayfun(@(x) repmat(x, length(MentalHealth_groups{x}), 1), 1:length(MentalHealth_groups), 'UniformOutput', false)');
% 
%     [p, tbl, stats] = anova1(grouped_data, group_labels);
%     
%     % Calculate eta-squared (η²)
%     SS_between = tbl{2, 2}; % Sum of squares for 'Groups'
%     SS_total = tbl{4, 2};   % Sum of squares for 'Total'
%     n2 = SS_between / SS_total



