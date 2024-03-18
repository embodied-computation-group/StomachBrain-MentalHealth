%function timeseries_statsCluster_Regression_vmp(subjects,cfgMain)

%{


Perform group level statistics comparing empirical versus chance PLV
by using the clustering randomization procedure provided by fieldtrip (Maris and Oostenveld
2007)

First it load the data of all subject (empirical and chance PLV) and puts
them into fieldtrip format. Thens it performs the statistics and then it
save into Physiens/ClusterResults a mask containign all significant voxels
(OutputFilename_mask),  each significant cluster (OutputFilename_Ncluster)
the tvalue in significant clusters (OutputFilename_tmap) and the tmap in
the whole brain (OutputFilename_WholeBrainTmap), it also saves a summary of
the statistics (OutputFilename_stats)

inputs:
subjects = subjectects in which the analysis will be performed -> global_subject list
cfgMain must contain fields
    kernelWidth,Timeseries2Regress,frequencySpread ,fOrder,beginCut,endCut
kernelWidth: with of the smoothing kernel from preprocessing, paper  =
3mm
cfgMain.Timeseries2Regress should be 'csf' to load residuals of csf
regression
fOrder : mutiplicative factor of the order of the filter
frequencySpread: spead of the time domain filter in hz * 1000, paper = 0.015 hz = 15,
begin and end cut are the voulmes that are discarded to avoid the filter
ringing artifact
cfgMain.transitionWidth is the transition width of the filter, paper is 15 
offset is with respect to EGG peaking filter, only for control analysis.
offset is in hz x 1000 e.g. and offset of 0.006 hz is a value of 6
clusterAlpha = first level threshold one-sided for determining candidate
clusters

numberofrandomizations  = number of times the labels empirical and
chance PLV will be switched. For this study we use 10000

Commented by IR 28/06/2017

Output: Y:\ClusterResults\kw3\CA0050\Cluster_nR10000_CA0050_kw3_fir2_fspread_015_fOrder_5_tw_15csfr
suffix _mask significant voxels exceeding monte carlo p > 0.025

%}


addpath(genpath('/home/ignacio/vmp_pipelines_gastro/StomachBrain_2021'))
addpath('/mnt/fast_scratch/toolboxes/fieldtrip/');
ft_defaults

cfgMain=global_getcfgmain
cfgMain.clusterAlpha=0.0005;
%% cfgMain parameters used in the script 
subjects=load('/home/ignacio/vmp_pipelines_gastro/subjectLists/list_4clusterretroicor.txt')
numrandomization =cfgMain.numberofrandomizations;
clusterAlpha = cfgMain.clusterAlpha;

n=length(subjects)
path2cluster = ['/mnt/fast_scratch/StomachBrain/data/groupresults/','MedianRot_RP_SA',sprintf('%.4d',cfgMain.alpha*10000)]
if    ~exist(path2cluster)
    mkdir(path2cluster)
end
clusterOutputFilename = strcat(path2cluster,filesep,'N_',num2str(n),'_nR',num2str(cfgMain.numberofrandomizations),'_CA',sprintf('%.4d',cfgMain.clusterAlpha*10000));
 

    empirical = zeros(n,339768); % Preallocate
    surrogate = empirical; % for calculating t value

for iS=1:n
    subj_idx = subjects(iS);
    

    dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']

    filenamePLV = strcat(dataDir,'sub-',sprintf('%.4d',subj_idx),'_PLVxVoxel_RP.nii.gz');

    filenamePLVSurrogate = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_medianRotationRP.nii.gz']; 



        
%    try
        PLVGroupEmpirical{iS} = ft_read_mri(filenamePLV); % Put into cell
        PLVGroupSurrogate{iS} = ft_read_mri(filenamePLVSurrogate);


        % Load empirical PLV  
        
        PLVGroupEmpirical{iS}.Nsubject = subjects(iS);
        
        % Preparing the FieldTrip structure needed for randomization     
        PLVGroupEmpirical{iS}.coh = PLVGroupEmpirical{iS}.anatomy; 
        PLVGroupEmpirical{iS} = rmfield(PLVGroupEmpirical{iS},'anatomy');
    
        
        % Load surrogate PLV and prepare structure for surrogate PLV
        
        PLVGroupSurrogate{iS}.Nsubject = subjects(iS);
        PLVGroupSurrogate{iS}.coh = PLVGroupSurrogate{iS}.anatomy;
        PLVGroupSurrogate{iS} = rmfield(PLVGroupSurrogate{iS},'anatomy');
        empirical(iS,:) = PLVGroupEmpirical{iS}.coh(:);
        surrogate(iS,:) = PLVGroupSurrogate{iS}.coh(:);

%    catch ME
%        fprintf('Error occurred for subj_idx: %d\n', subj_idx);
%        % Open file for writing, append failed subj_idx to file
%        fileID = fopen('/home/ignacio/vmp_pipelines_gastro/subjectLists/llist_mainpipelinefailed.txt', 'a');
%        fprintf(fileID, '%d\n', subj_idx);
%        fclose(fileID);
%    end

    

    
end



%% Run stats
% run statistics over subjects %
cfgStats=[];
cfgStats.dim         = PLVGroupEmpirical{1}.dim;
cfgStats.method      = 'montecarlo';
cfgStats.statistic   = 'ft_statfun_depsamplesT';
cfgStats.parameter   = 'coh';
cfgStats.correctm    = 'cluster';
cfgStats.numrandomization = numrandomization;
% cfgStats.alpha       = 0.05; % note that this only implies single-sided testing
cfgStats.alpha = cfgMain.alpha % NOW IN INPUT

cfgStats.clusteralpha = clusterAlpha;
cfgStats.tail        = 0;
%cfgStats.inside = indInside;
%cfgStats.outside = indOutside;


% con, the second condition is the median rotation PLV!
nsubj=numel(PLVGroupEmpirical);
cfgStats.design(1,:) = [1:nsubj 1:nsubj];
cfgStats.design(2,:) = [ones(1,nsubj) ones(1,nsubj)*2];
cfgStats.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
cfgStats.ivar        = 2; % row of design matrix that contains independent variable (the conditions)

stat = ft_sourcestatistics(cfgStats,PLVGroupEmpirical{:}, PLVGroupSurrogate{:});
% Actual call to the statistic function


% Print mask

data = stat.mask;
ninfo=niftiinfo(filenamePLV);ninfo.SpaceUnits='Millimeter';
data = reshape(data,66,78,66);
%niftiinfo(filename_brain_mask)
niftiwrite(data,strcat(clusterOutputFilename,'_mask.nii'),ninfo);


%tools_writeMri(data,strcat(clusterOutputFilename,'_mask'))

[h,p,ci,statsTtest] = ttest(empirical,surrogate);
tstatCluster = zeros(1,339768);
tstatCluster =statsTtest.tstat;
tstatCluster = reshape(tstatCluster,66,78,66);
tstatCluster(stat.mask==0) = 0;
niftiwrite(tstatCluster,strcat(clusterOutputFilename,'_tInMask.nii'),ninfo);



% Perform a ttest at every voxel to obtain a tmap
%empiricalBrain = empirical(:,indInside);
%surrogateBrain = surrogate (:,indInside);

%sumOfAbsT = sum(abs(statsTtest.tstat));
%sumOfPLV = sum(empiricalBrain(:)); % empirical PLV
%sumOfPLVChance = sum(surrogateBrain(:)); % chance PLV

%summaryResults.sumOfAbsT=sumOfAbsT;
%summaryResults.sumOfPLV=sumOfPLV;
%summaryResults.sumOfPLVChance=sumOfPLVChance;





%tXvoxel = zeros(1,339768);
%tXvoxel = statsTtest.tstat;
%tXvoxel = reshape(tXvoxel,66,78,66);

%% cohen d in cluster 
%cotstatCluster(stat.inside) =statsTtest.tstat;
%tools_writeMri(cohenD_cluster,strcat(clusterOutputFilename,'_effectSizeGasnet'))



%figure
%nhist(tstatCluster(find(tstatCluster)))

%figure
%nhist(cohenD_cluster(find(cohenD_cluster)))
%% Save and  write results
%save(strcat(clusterOutputFilename,'_stats.mat'),'stat')
%save(strcat(clusterOutputFilename,'_summary.mat'),'summaryResults')




%tools_writeMri(tstatCluster,strcat(clusterOutputFilename,'_tmap'))
%tools_writeMri(tXvoxel,strcat(clusterOutputFilename,'_WholeBrainTmap'))

%{
%% Get indexes of clusters

NClusters = length(stat.posclusters);%)fieldnames(stat.posclusters)
for iCluster = 1:NClusters
    indNPClustersSig(iCluster)  = stat.posclusters(1,iCluster).prob <= cfgStats.alpha ; % Find significant clusters in the stat structure
end

NPClusters = sum(indNPClustersSig);

% write them into HDD
for iCluster = 1:NPClusters 
    data = zeros(size(stat.mask));
    indCluster = find(stat.posclusterslabelmat == iCluster);
    data(indCluster)  = iCluster*10 ;
    tools_writeMri(data,strcat(clusterOutputFilename,'_map_clusterN',num2str(iCluster)))
end

%% Sumary of results


if NPClusters >= 1
sumTsigCluster = stat.posclusters(1,1:NPClusters).clusterstat;
summaryResults.NSPClusters = NPClusters;
summaryResults.sumTsigCluster=sumTsigCluster;

else
  summaryResults.NSPClusters  = 0;
  summaryResults.sumTsigCluster= 0;

end


thenD_cluster = tstatCluster ./sqrt((length(subjects)+length(subjects))) ;

data = stat.posclusterslabelmat;
data(isnan(data))=0;
mask_nonan = stat.mask;
mask_nonan(isnan(stat.mask)) = 0;
data(~mask_nonan)=0;
tools_writeMri(data,strcat(clusterOutputFilename,'_ClusterMap'))


%end
mean_empirical=mean(empirical);
mean_empirical = reshape(mean_empirical,66,78,66);
tools_writeMri(mean_empirical,strcat(clusterOutputFilename,'_meanempirical'))

mean_surrogate=mean(surrogate);
mean_surrogate = reshape(mean_surrogate,66,78,66);
tools_writeMri(mean_surrogate,strcat(clusterOutputFilename,'_meansurrogate'))

tools_writeMri(mean_empirical-mean_surrogate,strcat(clusterOutputFilename,'_meandifference'))


%}