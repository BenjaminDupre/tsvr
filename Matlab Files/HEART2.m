%%  Heart Rate varaibility with circular  kstatistics. 16 Januar 
% Analysing for 1 Signal
%% Initialization. 
fs=133;
gr=false;
i=18;
%% Finding Haptic Stimuli Onset. 
[rows, cols, vals] = find(all2(i).data.leftHandVibration=="True" | all2(i).data.rightHandVibration=="True");
[rows2, cols2, vals2] = find(all2(i).data.leftHandVibration=="False" & all2(i).data.rightHandVibration=="False");
clear cols vals vals2 cols2
% Creating separated sets. 
SI = [rows all2(i).data.ECG(rows) true(size(rows))];
NO = [rows2 all2(i).data.ECG(rows2) false(size(rows2))];
A = [SI ; NO];
ECG_vibration = sortrows(A,1);
clear A
% Correcting for missinserted none vibrations values 
for j = 1+3:size(ECG_vibration,1)-3
    if ECG_vibration(j,3) ==0 & ECG_vibration(j:j+3,3)==1 | ECG_vibration(j-3:j,3)==1
        ECG_vibration(j,3) =1;
    end
end
% Results Visulization. 
plot(ECG_vibration(:,1),ECG_vibration(:,2)); hold on;
plot(ECG_vibration(ECG_vibration(:,3)==1,1),ECG_vibration(ECG_vibration(:,3)==1,2),'r'); 
title('Heartbeat (Vibration/No Vibration)')
xlabel('row number')
ylabel('Seconds'); hold off;

%% Runnig Multiresolution Teager Energy Operator (MTEO) for the unsupervised 
%  clustering of action potentials

[R,Q,S,T,P_w] = heplab_T_detect_MTEO(ECG_vibration(:,2),fs,gr);             % algorithm from HEPLAB

plot(ECG_vibration(:,2), '-p','MarkerIndices',R(:,1), ...                   % to visually check the quality of the allocation. 
'MarkerFaceColor','green', ...
'MarkerSize',15)

figure; plot (diff(T(2:end,1)/133),':b'); hold on;
plot(movmean(diff(T(2:end,1)/133),5),'r')                                   % to visually check the quality of the allocation.
title('Interbeat Intervals')
xlabel('Beats')
ylabel('Seconds')
hold off;   
%% Did the vibration started on Systole or Diastole?
% Detecting where did the vibration begin. 
sum(diff(ECG_vibration(:,1)))


%% Cutting ECG data into entire cardiac cycles.
    
% We need a matrix that includes the ECG signal in the following structure 
% |ptcp|Set|Trial|Stimulus|ECG|

% OK; so from the variable levelCounter is not exactly what we consider a 
% tria,. it is more meaningfull for the operation of the game. The we must reach 
% out for when we build the levels for our RT varaibles. To do so we will
% use from the rtime data the start and begininig levels which are
% cratiereas that adjust to trial considerations. The vector will look like
% this:
cardio = [];
for j=1:size(all2(i).rtime.data,1)
    ECG = all2(i).data.ECG(all2(i).rtime.data.start(j):...
        all2(i).rtime.data.end(j));
    ECG(:,2)= all2(i).rtime.data.set(j);
    ECG(:,3)= all2(i).rtime.data.lvl(j);
    ECG(:,4)= all2(i).rtime.data.stimulus(j);
    ECG(:,5)= i;
    cardio = [cardio; ECG];
end
%% Saving Data To Use it in R
writematrix( cardio,append('/Users/calypso/Dropbox/',...
        'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
        'P1_propioception/R_tsvr_presentation/data/', 'heart_data',...
         '.csv')) 
%% Calculating Relative Position Relative Position of the Stimulus Onset 
%within the Cardiac Cycle.
