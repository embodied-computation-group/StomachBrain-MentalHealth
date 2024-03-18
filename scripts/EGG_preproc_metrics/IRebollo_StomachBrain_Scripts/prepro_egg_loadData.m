function [dataInFieldtrip, markersInFieldtrip] = prepro_egg_loadData(subj_idx,fileType,sample)
%{

Function to retrieve subject EGG and IRM volume markers recorded inside the scanner. This function is called by prepro_egg
 
Input:
subj_idx= eg '8','12'
dataType= 'EGG' for electrogastrogram or 'EKG' for electrocardiogram
session = 
1 rest
2 eba
3 motor
4 somaflow
5 mt

Output: Data and markers in fieldtrip format

IR 14/05/2018 adapted 2navigastric


%}

REST=strcmp(fileType,'REST');
EBA=strcmp(fileType,'EBA');
MOTOR=strcmp(fileType,'MOTOR');
MT=strcmp(fileType,'MT');
SOMAFLOW=strcmp(fileType,'SOMAFLOW');




if REST==1 % data when the irm scanner was on
    pathToBrainAmp = prepro_egg_path2data(subj_idx,'brainamp',sample);
    pathToMarkers = prepro_egg_path2data(subj_idx,'brainampMarkers',sample);
    
    %Markers
    cfg = []; %structure de configuration
    cfg.dataset = pathToMarkers; % nom du fichier d'int�r�t
    cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
    cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
    cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
    cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
    cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
    markersInFieldtrip = ft_definetrial(cfg);
    
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
    
elseif EBA==1
    pathToBrainAmp = prepro_egg_path2data(subj_idx,'EBA',sample);
    pathToMarkers = prepro_egg_path2data(subj_idx,'EBA',sample);
    
    %Markers
    cfg = []; %structure de configuration
    cfg.dataset = pathToMarkers; % nom du fichier d'int�r�t
    cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
    cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
    cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
    cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
    cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
    markersInFieldtrip = ft_definetrial(cfg);
    

    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
    
elseif MOTOR==1
    pathToBrainAmp = prepro_egg_path2data(subj_idx,'MOTOR',sample);
    pathToMarkers = prepro_egg_path2data(subj_idx,'MOTOR',sample);
    
    %Markers
    cfg = []; %structure de configuration
    cfg.dataset = pathToMarkers; % nom du fichier d'int�r�t
    cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
    cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
    cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
    cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
    cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
    markersInFieldtrip = ft_definetrial(cfg);
    
    
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
    
elseif SOMAFLOW==1
    pathToBrainAmp = prepro_egg_path2data(subj_idx,'SOMAFLOW',sample);
    pathToMarkers = prepro_egg_path2data(subj_idx,'SOMAFLOW',sample);
    
    %Markers
    cfg = []; %structure de configuration
    cfg.dataset = pathToMarkers; % nom du fichier d'int�r�t
    cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
    cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
    cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
    cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
    cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
    markersInFieldtrip = ft_definetrial(cfg);
    
    
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
    
elseif MT==1
    pathToBrainAmp = prepro_egg_path2data(subj_idx,'MT',sample);
    pathToMarkers = prepro_egg_path2data(subj_idx,'MT',sample);
    
    %Markers
    cfg = []; %structure de configuration
    cfg.dataset = pathToMarkers; % nom du fichier d'int�r�t
    cfg.trialfun = 'ft_trialfun_general'; % fonction d�finissant les essais
    cfg.trialdef.eventtype = 'Response'; % type d'�v�nement
    cfg.trialdef.eventvalue = 'R128'; % valeur d'�v�nement
    cfg.trialdef.prestim = 1; % secondes �coul�es avant l'�v�nement
    cfg.trialdef.poststim = 1; % secondes �coul�es apr�s l'�v�nement
    markersInFieldtrip = ft_definetrial(cfg);
    
    
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
end

EGG=strcmp(fileType,'EGG');
EKG=strcmp(fileType,'EKG');

if EGG==1
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'EGG_1', 'EGG_2', 'EGG_3', 'EGG_4'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
elseif EKG==1
    %Data
    cfg = [];    %configuration structure
    cfg.dataset = pathToBrainAmp;
    cfg.channel = {'ECG_6', 'ECG_7', 'ECG_8'};
    dataInFieldtrip = ft_preprocessing(cfg); %structure with data (as one long continuous segment)
    
end
end