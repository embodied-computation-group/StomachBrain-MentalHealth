function path2subject = global_path2subject(subj_idx,sample)
% path to subject specific folder
% path2subject = strcat(global_path2root,'Subjects',filesep,'Subject',sprintf('%.2d',subj_idx),filesep);
path2subject = strcat(global_path2root(sample),'subj',sprintf('%.2d',subj_idx),filesep);
% path2subject = strcat(global_path2root,'Subject',sprintf('%.2d',subj_idx),filesep);


end