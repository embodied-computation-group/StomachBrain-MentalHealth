function timeseries_gastropipeline_acompcor_native(subj_idx,cfgMain)

%{
Insert documentatoin here
% Do this in fmriprep native space and not resliced

%}


% Import

[BOLDtimeseries] =timeseries_import2matlab_3mm(subj_idx,cfgMain)
[residuals] =timeseries_preprocessBOLD_3mm(subj_idx,cfgMain,BOLDtimeseries);clear BOLDtimeseries
timeseries_preparePhases_3mm(subj_idx,cfgMain,residuals);clear residuals
timeseries_mapPLV_3mm(subj_idx,cfgMain);

end