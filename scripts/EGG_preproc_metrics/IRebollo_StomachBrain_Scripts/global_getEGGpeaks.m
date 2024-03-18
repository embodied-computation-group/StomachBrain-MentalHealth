function EGGpeaks =  global_getEGGpeaks

%{
Load the file containing the channel number and exact frequency for all subjects during the fMRI acquisition,
which was manually estimated in the first call of prepro_egg and stored in 
the log file together with the EGG phase timeseries in each subject timeseries folder.
The file to be loaded  was created by the function prepro_egg_saveChannelInfo
Commented IR 27/06/2017

%}
% load(strcat('D:\NAVIGASTRIC\stomachBrainNavigastric\files\','EGG_peaks_info'))
load(['Z:\scripts\STOMACH_BRAIN\files\EGG_peaks_info_phys'])
% load(strcat('D:\NAVIGASTRIC\test2pipelines\scripts\stomachBrainNavigastricTest2pipelines\files\','EGG_peaks_info'))


end