function tools_writeMri(data,filename)
% data filename
%{ 
Write 3d or 4d data in nifti file using fieldtrip
parameters are specified for PHYSIENS experiment (dimensions)
IR 26/03/2015
%}
mri=[];

% mri.transform = ...
%     [ -3 0 0 81;...
%     0 3 0 -115;...
%     0 0 3 -73; ...
%     0 0 0 1];
% % physiens voxels transform


% mri.transform = ...
%     [-2 0 0 80;...
%     0 2 0 -114;...
%     0 0 2 -72; ...
%     0 0 0 1];
% navigastric voxels transform


mri.transform = ...
    [ -3 0 0 -96.5;...
    0 3 0 -132.5;...
    0 0 3 -73.5; ...
    0 0 0 1];

mri.coh = data;
mri.dim=[66,78,66]; % for test2pipelines
% mri.dim=[53,63,52];

% mri.dim=[79,95,79];



cfg.parameter = 'coh';
cfg.filename =  filename;
cfg.filetype    = 'nifti';
cfg.coordsys      = 'spm';
cfg.scaling = 'no';
cfg.datatype = 'double';


ft_volumewrite(cfg,mri)

end