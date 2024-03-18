function [voxel_index]=tools_getIndexExampleVoxelVMP_3mm(subj_idx)

    filename_brain_mask = ['/mnt/fast_scratch/StomachBrain/data/fMRI_timeseries/sub-',sprintf('%.4d',subj_idx),'/sub-',sprintf('%.4d',subj_idx),'_brainmask_3mmV.nii.gz'];
    insideBrain= logical(niftiread(filename_brain_mask));
    voxel_index=zeros(66,78,66);
    voxelCoordinates = sub2ind([66,78,66],34,17,29);% for 1mm vmp
    voxel_index(voxelCoordinates)=true;
    voxel_index(~insideBrain)=[];
    voxel_index=logical(voxel_index);




end

