%% ======== Delineates ECG based on MTEO Algorithm ============== %%
% It uses other scripts to structure the load of the data for every 
% participant, it checks equal amount of feedbacktype for every 
% participant, it computes and stores response times and saves them 
% on the structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
allFolder = 'your working directory';
cd(allFolder)
parti = dir(allFolder);
%This filters out all the items in the main folder that are not directories
parti(~[parti.isdir]) = [];
%And this filters out the parent and current directory '.' and '..'
tf = ismember( {parti.name}, {'.','..','__MACOSX'});
parti(tf) = [];
numberOfFolders = length(parti);
all2(5).ptcp = [];
for i=1:numberOfFolders
    ptcp=parti(i).name;
    all2(i).ptcp = ptcp;
    run(append(allFolder,'load_everything.m'))
    all2(i).data = all;
    run(append(allFolder, 'building_response_time.m'))
    all2(i).rtime = r_time;
end
clear all parti ptcp i handrot numberOfFolders subdirs r_time B % Getting rid of all intermidiate variables. 
toc


