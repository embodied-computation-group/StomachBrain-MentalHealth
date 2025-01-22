function RespBrain_NuisanceOnly_spm(savedir, scans, regress_file)

% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/home/leah/Git/StomachBrain-MentalHealth/scripts/CCA/Control_analyses/RespBrain/spm/RespBrain_spm_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(savedir);
    inputs{2, crun} = cellstr(scans); % fMRI model specification: Scans
    inputs{3, crun} = cellstr(regress_file); % fMRI model specification: nuisance regressors file
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

end