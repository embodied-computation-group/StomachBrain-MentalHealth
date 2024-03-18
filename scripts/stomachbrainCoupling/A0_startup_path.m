function [cfgMain]=A0_startup_path()
    addpath(genpath('/home/ignacio/vmp_pipelines_gastro/'))
addpath('/mnt/fast_scratch/toolboxes/fieldtrip/');
ft_defaults
cfgMain=global_getcfgmain;

end
