%% ======== Delineates ECG based on MTEO Algorithm ============== %%
% It uses other scripts to structure the load of the data for every 
% participant, it checks equal amount of feedbacktype for every 
% participant, it computes and stores response times and saves them 
% on the structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
allFolder = '/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/Data_Wrangling/Matlab Analysis/Data_Wrangling/';
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
    run('/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/Data_Wrangling/Matlab Analysis/Data_Wrangling/load_everything_13_10_20_.m')
    all2(i).data = all;
    run('/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/Data_Wrangling/Matlab Analysis/Data_Wrangling/building_response_time.m')
    all2(i).rtime = r_time;
end
clear all parti ptcp i handrot allFolder numberOfFolders subdirs r_time B   % Getting rid of all intermidiate variables. 

toc


