



addpath(genpath('/home/ignacio/vmp_pipelines_gastro/StomachBrain_2021'))
addpath('/mnt/fast_scratch/toolboxes/fieldtrip/');
ft_defaults
cfgMain=global_getcfgmain;

%allSubjs=load('/home/ignacio/vmp_pipelines_gastro/list_clean_subjects.txt');

%loadSubjecList
allSubjs=load('/home/ignacio/vmp_pipelines_gastro/subjectLists/list_4clusterretroicorMRIQC.txt');


for iSubj=1:length(allSubjs)
        
    subj_idx=allSubjs(iSubj)



    [BOLDtimeseries] =timeseries_import2matlab_3mm(subj_idx,cfgMain)
    [residuals] =timeseries_preprocessBOLD_controlBOLDSTD(subj_idx,cfgMain,BOLDtimeseries);clear BOLDtimeseries

    rootDir = global_path2root_folder
    dataDir=[global_path2root,'fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/']
    BOLDSTDXVoxelFilename = [dataDir,'sub-',sprintf('%.4d',subj_idx),'_STDxVoxel_RP.nii']; % output filename


    filename_brain_mask = ['/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/sub-',sprintf('%.4d',subj_idx),'_brainmask_3mmV.nii.gz'];
    indBrain= logical(niftiread(filename_brain_mask));
    indNoBrain = ~indBrain;
    empPLV = zeros (66,78,66); % empty 3d Volume for storing empirical PLV
    empPLV = empPLV(:); % transformed into a vector
    empPLV(indBrain)= std(residuals,[],1); % compute PLV for each voxel
    empPLV(indNoBrain) = 0;
    PLV3D = reshape(empPLV,66,78,66); % reshape it from vector to matrix

    %tools_writeMri(PLV3D,PLVXVoxelFilename)
    niftiheader= (niftiinfo(filename_brain_mask));
    niftiheader.Datatype = 'double';
    niftiwrite(PLV3D,BOLDSTDXVoxelFilename,niftiheader,'Compressed',true)


end