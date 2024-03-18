function [output] = prepro_egg_path2data(subj_idx,fileType,sample)
%{
This funcion get the full path of different kind of files, e.g. brainamp markers, for a particular
subject. This function is called by prepro_egg_loadData

input:
subject = string, e.g. '01' '02' '03'
filtype= 'brainamp', 'brainampMarkers' 'fmri' , 'brainampWOIRM', 'brainampMarkersWOIRM'


example call:
pathtBrainAmp = getFilesPath('08','brainamp')

Output: string containing path to data

Commented IR 27/06/2017

%}
%%

subjectFolder= global_path2subject(subj_idx,sample);

% Check which kind of file to retrieve
brainamp=strcmp(fileType,'brainamp');
brainampMarkers=strcmp(fileType,'brainampMarkers');
% brainampWOIRM=strcmp(fileType,'brainampWORIM');
% brainampMarkersWOIRM=strcmp(fileType,'brainampMarkersWOIRM');
fmri=strcmp(fileType,'fmri');
EBA=strcmp(fileType,'EBA');
MOTOR=strcmp(fileType,'MOTOR');
MT=strcmp(fileType,'MT');
SOMAFLOW=strcmp(fileType,'SOMAFLOW');



%% PHYSIENS
if sample == 2
    
if brainamp==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'with MRI',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

if brainampMarkers==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'with MRI',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr header files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

elseif sample ==1
%% NAVIGASTRIC
if brainamp==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

if brainampMarkers==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr header files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

%% 
if EBA==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'Tasks',filesep,'EBA',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

if MOTOR==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'Tasks',filesep,'MOTOR',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

if MT==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'Tasks',filesep,'MT',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end


if SOMAFLOW==1
    brainampDir = strcat(subjectFolder,'Brainamp',filesep,'Tasks',filesep,'SOMAFLOW',filesep);
    files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
    filename = {files.name}';%'# file names
    output = char(strcat(brainampDir,filename));
end

% if brainampWOIRM==1
%     brainampDir = strcat(subjectFolder,'Brainamp',filesep,'without MRI',filesep);
%     files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr files
%     filename = {files.name}';%'# file names
%     output = char(strcat(brainampDir,filename));
% end
%
% if brainampMarkersWOIRM==1
%     brainampDir = strcat(subjectFolder,'Brainamp',filesep,'without MRI',filesep);
%     files= dir( fullfile( brainampDir,'*.vhdr')); %# list all *.vhdr header files
%     filename = {files.name}';%'# file names
%     output = char(strcat(brainampDir,filename));
% end

if fmri==1
    fmriDir=strcat(subjectFolder,'fMRI');
    files= dir( fullfile( fmriDir,'swutrf*.nii')); %# list all swaf files
    filenames = {files.name}';%'# file names
    output = filenames;
end

end

end