
% master wrapper for individual heart-brain maps

datafiles_root = '/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/'; % use same scans as stomach-brain
fmri_files = dir(fullfile(datafiles_root, '**', 'sub*_smooth3mm.nii.gz'));

% loop for each participant
for n = 1 : length(fmri_files)
    
    % unzip fMRI temporally
    gunzip(fullfile(fmri_files(n).folder, fmri_files(n).name)) 
    fmri_filename =  fullfile(fmri_files(n).folder, fmri_files(n).name(1:length(fmri_files(n).name)-3));
    
    % nuissance regressors (we dont want to convolve with HRF)
    subID = fmri_filename(57:60);
    regress_path = sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRVmotionacompcor_regressors/%s_regressors_hrvHFhrvLF6motion6acompcor.mat', subID);
    % skip subject if no regressor file
    if exist(regress_path) == 0
        continue
    end
    regressors = load(regress_path);
    %regress_len = length(regressors.R);
    
    % names of scanfile (with volume nums at end) for SPM
    niftifile_info = niftiinfo(fmri_filename);
    %no_frames = niftifile_info.ImageSize(end);
    first_frame = min(find(isnan(regressors.R(:,1)) == 0));
    last_frame = max(find(isnan(regressors.R(:,1)) == 0));
    %frame_names = cell(regress_len,1);
    for p = first_frame:last_frame %no_frames % get number of frames/volumes as length of hrv regressors 
        frame_names{p-(first_frame-1),1} = sprintf('%s,%d', fmri_filename, p);
    end
    
    % cut NaNs from regressor file
    R = regressors.R(first_frame:last_frame, :);
    names = regressors.names;
    regress_path_aligned = sprintf('/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/HRVmotionacompcor_regressors/%s_regressors_hrvHFhrvLF6motion6acompcor_noNaN.mat', subID);
    save(regress_path_aligned, 'R', 'names');
    
    % save path of heart-brain coupling each subject
    savepath = sprintf('/mnt/raid0/scratch/BIDS/derivatives/heart-brain_coupling/%s/',subID);
    if exist(savepath, 'dir') == 0
        mkdir(savepath)
    end
    
    % run SPM batch
    HeartBrain_spm(savepath, frame_names, regress_path_aligned);
    
    % zip fMRI again & delete unzipped
    gzip(fmri_filename);
    delete(fmri_filename);
    
    clearvars -except fmri_files
    toc
end
