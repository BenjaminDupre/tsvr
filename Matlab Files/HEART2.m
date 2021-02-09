%%  Heart Rate varaibility with circular  kstatistics. 16 Januar 
% Analysing for 1 Signal
%% Initialization. 
fs=133;
gr=false;
i=4;
%% Finding Haptic Stimuli Onset. 
[rows, cols, vals] = find(all2(i).data.leftHandVibration=="True" |...
    all2(i).data.rightHandVibration=="True");
[rows2, cols2, vals2] = find(all2(i).data.leftHandVibration=="False" ...
    & all2(i).data.rightHandVibration=="False");
clear cols vals vals2 cols2
% Creating separated sets. 
SI = [rows all2(i).data.ECG(rows) true(size(rows))];
NO = [rows2 all2(i).data.ECG(rows2) false(size(rows2))];
A = [SI ; NO];
ECG_vibration = sortrows(A,1);

% Correcting for missinserted none vibrations values 
for j = 1+4:size(ECG_vibration,1)-4
    if ECG_vibration(j,3) ==0 & ECG_vibration(j:j+4,3)==1 | ...
            ECG_vibration(j-4:j,3)==1
        ECG_vibration(j,3) =1;
    end
end
clear A rows rows2 SI NO j 
% Results Visulization.
plot(ECG_vibration(:,1),ECG_vibration(:,2)); hold on;
plot(ECG_vibration(ECG_vibration(:,3)==1,1),ECG_vibration(...
    ECG_vibration(:,3)==1,2),'r'); 
title('Heartbeat (Vibration/No Vibration)')
xlabel('row number')
ylabel('Seconds'); hold off;

%% Runnig Multiresolution Teager Energy Operator (MTEO) for the unsupervised 
%  clustering of action potentials
[R,Q,S,T,P_w] = heplab_T_detect_MTEO(ECG_vibration(:,2),fs,gr);             % algorithm from HEPLAB
clear Q S P_w fs gr
plot(ECG_vibration(:,2), '-p','MarkerIndices',R(:,1), ...                   % to visually check the quality of the allocation. 
'MarkerFaceColor','green', ...
'MarkerSize',15)
% Pending to visually correct missallocated R y T 
figure; plot (diff(T(2:end,1)/133),':b'); hold on;
plot(movmean(diff(T(2:end,1)/133),5),'r')                                   % to visually check the quality of the allocation.
title('Interbeat Intervals')
xlabel('Beats')
ylabel('Seconds')
hold off;   
%% Did the vibration started on Systole or Diastole?
% Detecting the starting point . for the virbation
[vib, cols, vals] = find(ECG_vibration(:,3)==1);
[vib_start, cols2, vals2] = find(diff(vib)>55);
vib_start = vib_start+1;
clear cols cols2 vals vals2 vib
% controlling visually if the placement is ok (the first placement is lost)
plot(ECG_vibration(:,1),ECG_vibration(:,2)); hold on;
plot(ECG_vibration(ECG_vibration(:,3)==1,1),ECG_vibration(...
    ECG_vibration(:,3)==1,2),'.-','MarkerIndices', vib_start, ...
    'MarkerFaceColor','green','MarkerSize',15); 
title('Heartbeat for Vibration No Vibration)')
xlabel('row number')
ylabel('V'); hold off;
% labelling whether the starting point is diastole or sistole 
str1="T";
str2="R";
str3="VS";
T_t = repelem(str1,size(T,1)).';
R_r = repelem(str2,size(R,1)).';
V_s = repelem(str3,size(vib_start,1)).';

A = table(T(:,1),T_t, 'VariableNames',{'row','Zustand'});
B = table(R(:,1),R_r, 'VariableNames',{'row','Zustand'});
C = table(vib_start(:,1),V_s, 'VariableNames',{'row','Zustand'});
points= [A; B; C];
points =sortrows(points, "row");

points.zyklus= string(zeros(height(points),1));

for k = 1:height(points)
    if points(k,:).Zustand=="VS"
        if points(k-1,:).Zustand=="R" & points(k+1,:).Zustand=="T"
            points.zyklus(k)="Systole";
        elseif points(k-1,:).Zustand=="T" & points(k+1,:).Zustand=="R"
            points.zyklus(k)="Diastole";
        end
    else
        points.zyklus(k)= "None Vibrating R ot T";
    end    
end    
% Checking Results
tabulate(points.zyklus)
points(points.zyklus=="0",:)

% %% Saving Data To Use it in R
% writematrix( cardio,append('/Users/calypso/Dropbox/',...
%         'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
%         'P1_propioception/R_tsvr_presentation/data/', 'heart_data',...
%          '.csv')) 
%% Calculating Relative Position Relative Position of the Stimulus Onset 
%within the Cardiac Cycle.
