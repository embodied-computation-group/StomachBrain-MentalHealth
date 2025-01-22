%% Combine instantaneous hrv regressors with 6 motion & 6 acompcor
file = dir('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRV_regressors/*.mat');
for n = 1 : length(file)
    load(fullfile(file(n).folder, file(n).name));
    
    %     % add NaN to end of IBI regressors (last heartbeat not at exact acquisition
    %     % of last fMRI volume)
    %     if length(HFHRVregressor) < 600
    %         HFHRVregressor(length(HFHRVregressor)+1:600) = NaN;
    %     end
    %     if length(LFHRVregressor) < 600
    %         LFHRVregressor(length(LFHRVregressor)+1:600) = NaN;
    %     end
    
    % load confounds file
    subID = file(n).name(1:4);
    confounds_path = sprintf('/mnt/raid0/scratch/BIDS/derivatives/fmriprep/sub-%s/ses-session1/func/sub-%s_ses-session1_task-rest_run-001_desc-confounds_timeseries.tsv',subID,subID);
    if exist(confounds_path, 'file')
        confounds = readtable(confounds_path, 'FileType', 'text', 'Delimiter', '\t');
        
%         % check length of regressors are the same
%         if not(length(HFHRVregressor) == length(LFHRVregressor))
%             sprintf('sub-%s: HRV regressors not same length', subID)
%             continue
%         end
%         
%         % cut confounds to be same length as hrv regressors (ends at last heartbeat)
%         confounds = confounds(1:length(HFHRVregressor),:);
        
        % merge and save regressors
        motion = {'rot_x', 'rot_y', 'rot_z', 'trans_x', 'trans_y', 'trans_z'};
        acompcor = {'a_comp_cor_00', 'a_comp_cor_01', 'a_comp_cor_02', 'a_comp_cor_03', 'a_comp_cor_04', 'a_comp_cor_05'};        
        R = table2array([table(RespVregressor), confounds(:, [motion, acompcor])]);
        names = ['RespVariability', motion, acompcor];
        save(sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRVmotionacompcor_regressors/%s_regressors_hrvHFhrvLF6motion6acompcor.mat', subID), 'R', 'names')
    else
        sprintf('sub-%s: no confounds file', subID)
    end
    clearvars -except file
end
