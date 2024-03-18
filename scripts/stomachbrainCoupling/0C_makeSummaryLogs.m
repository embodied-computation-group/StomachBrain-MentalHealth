filepaths = dir('/mnt/fast_scratch/StomachBrain/data/EGG_preproc/*log.mat');
filepaths
ratings = zeros(length(filepaths),1);
peaks = zeros(length(filepaths),1);
for n =1:length(filepaths)
    logs{n} = load([filepaths(n).folder filesep filepaths(n).name]);
    logsummary(n).automaticChannel = logs{n}.logEGGpreprocessing.automaticChannelSelection;
    logsummary(n).cfg = logs{n}.logEGGpreprocessing.cfgMain;
    logsummary(n).Filename = logs{n}.logEGGpreprocessing.outputFilename;
    logsummary(n).SubID = logs{n}.logEGGpreprocessing.subjectNumber;
    logsummary(n).BestChannel = logs{n}.logEGGpreprocessing.bestChannel;
    logsummary(n).MostPowerChan = logs{n}.logEGGpreprocessing.mostPowerfullChannel;
    logsummary(n).peaks = logs{n}.logEGGpreprocessing.mostPowerfullFrequency;
    logsummary(n).ConfBestChan = logs{n}.logEGGpreprocessing.confidencechannel_best;
    logsummary(n).ratings = logs{n}.logEGGpreprocessing.confidencechannel_quality;
    if isfield(logs{n}.logEGGpreprocessing,'notes')
        logsummary(n).notes = logs{n}.logEGGpreprocessing.notes;
    end
end
for ind = 1:length(logsummary)
    peaks(ind) = logsummary(ind).peaks;
    confbest(ind) = logsummary(ind).ConfBestChan;
    ratings(ind) = logsummary(ind).ratings;
end
% peaks(peaks > 0.1) = NaN;figure; hist(peaks) %0.5 high incorrect freq
% figure; hist(confbest)
% ratings(ratings > 7) = NaN; figure; hist(ratings)
% log_tricky=logsummary(ratings > 0.25 & ratings < 0.75)
% log_notsotricky=logsummary(ratings > 0.75 & ratings < 0.90)

sum(ratings>0.89)

log_clean=logsummary(ratings>0.89)
sum(ratings>0.89)

writetable(struct2table(log_clean),'/mnt/fast_scratch/StomachBrain/data/EGG_preproc/log_clean.csv')