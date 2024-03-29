%%==Heart Rate varaibility with circular  kstatistics. 16 Januar=========== 

% Analysing for 1 Signal
%%======================= Initialization.================================== 
fs=133;                                                                     % freq for heart cycle algoorithm
gr=false;                                                                   % for heart cycle algoorithm
i=5; % borrar y hacer foward loop. 
behavioral_a =[];                                                           % this creates goal matrix
mistakes=[];                                                                % this creates intrumental matrix
mistakesf=[];  
%% ============== Creating Behavioral file to run in R ====================
for i=1:size(all2,2)
    responsetime = all2(i).rtime.data;
    responsetime.ptcp = ones(size(all2(i).rtime.data,1),1)*i;
    behavioral_a = [behavioral_a;responsetime ];
end
%% ============== Adding mistakes to Behavioral file=======================
                                                           
for prsnj = 1:size(all2,2)                                                  % this instruct to go over all participants
    data = all2(prsnj).data;                                                % this extracts the data for the particulart partcp
    A = zeros(size(data,1)-1,4);                                            % this preallocates space for all data
    for line=1:size(data,1)-1                                               % this indicates to go over every row
        A(line,3) = data.correctCounter(line+1)~=data.correctCounter(line); % this looks for diferences in correct counter
        A(line,1) = data.set(line);                                         % this adds to A the set number 
        A(line,2) = data.levelCounter(line);                                % this ads the level counter
        A(line,4) = data.feedbackType(line);                                %this adds the feedback the the moment
    end
    indx = find(A(:,3)==1);                                                 % this gets the exact moment where the correct changed 
    A = A(indx,:);
    mistakes = [A(diff(A(:,2))>1,:) prsnj*ones(size(A(diff(A(:,2))>1,:),1),1) ];
    mistakesf = [mistakesf; mistakes];
end

clear data A 

mistakesf(:,2) = mistakesf(:,2)+1;                                          % this goes back to the exact level nummber where the mistake was done.
mistakes_ag = array2table(mistakesf, 'VariableNames',{'set',...
    'level','mistake','stimuli','participant'});                            % this adds names 

clear line prsnj mistakes mistakesf indx

% It uses variable mistakes_ag to add a variable that has a value one when
% the ball is placed in the wrong hold. 
for i=1:size(mistakes_ag,1)
    behavioral_a.accuracy(behavioral_a.ptcp == mistakes_ag.participant(i)&...
        behavioral_a.set == mistakes_ag.set(i)&...
        behavioral_a.lvl == mistakes_ag.level(i),:)=1;
end

clear responsetime mistakes_ag i

behavioral_a.zyklus = string(zeros(height(behavioral_a),1));                % creating column to put heart cycle strings in. 
%% ===================Finding Haptic Stimuli Onset.======================== 
for i=1:size(all2,2)
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
    try 
        [R,Q,S,T,P_w] = heplab_T_detect_MTEO(ECG_vibration(:,2),fs,gr); 

    clear Q S P_w 
    plot(ECG_vibration(:,2), '-p','MarkerIndices',R(:,1), ...                % to visually check the quality of the allocation. 
    'MarkerFaceColor','green', ...
    'MarkerSize',15)
    % Pending to visually correct missallocated R y T 
    figure; plot (diff(T(2:end,1)/133),':b'); hold on;
    plot(movmean(diff(T(2:end,1)/133),5),'r')                                % to visually check the quality of the allocation.
    title('Interbeat Intervals')
    xlabel('Beats')
    ylabel('Seconds')
    hold off;   
    %% ===========Did the vibration started on Systole or Diastole?============
    %------------ Detecting the starting point . for the virbation------------%
    [vib, cols, vals] = find(ECG_vibration(:,3)==1);
    [vib_start, cols2, vals2] = find(diff([0; vib])>55);                    % arbitrary value to correct for randomly present "false" virbations. 
    vib_start = vib_start+1;
    clear cols cols2 vals vals2 

    plot(ECG_vibration(:,1),ECG_vibration(:,2)); hold on;                   % controlling visually if the placement is ok (the first placement is lost)
    plot(ECG_vibration(ECG_vibration(:,3)==1,1),ECG_vibration(...
        ECG_vibration(:,3)==1,2),'.-','MarkerIndices', vib_start, ...
        'MarkerFaceColor','green','MarkerSize',15); 
    title('Heartbeat for Vibration No Vibration)')
    xlabel('row number')
    ylabel('V'); hold off;
    %------Identify in one array for all identified heart cycles--------------% 
    str1="T";
    str2="R";
    str3="VS";
    T_t = repelem(str1,size(T,1)).';
    R_r = repelem(str2,size(R,1)).';
    tool2 =  vib(vib_start,1);
    V_s = repelem(str3,size(tool2,1)).';

    A = table(T(:,1),T_t, 'VariableNames',{'row','Zustand'});
    B = table(R(:,1),R_r, 'VariableNames',{'row','Zustand'});
    C = table(tool2,V_s, 'VariableNames',{'row','Zustand'});
    points= [A; B; C];
    points =sortrows(points, "row");

    points.zyklus= string(zeros(height(points),1));
    %--Asignating for the array the string stating whther systole or diastole-%
    for k = 1:height(points)
        if points(k,:).Zustand=="VS"
            if points(k-1,:).Zustand=="R" & points(k+1,:).Zustand=="T"
                points.zyklus(k)="Systole";
            elseif points(k-1,:).Zustand=="T" & points(k+1,:).Zustand=="R"
                points.zyklus(k)="Diastole";
            end
        else
            points.zyklus(k)= "None Starting Vibration";
        end    
    end    

    tabulate(points.zyklus)                                                     % Checking Results
    points(points.zyklus=="0",:)

    clear A C B str1 str2 str3 T T_t V_s R R_r                                        % Clearing tool variables. 
    %% =========Asignating Heart Cycle lavel into Behavioral Table.======== 
    %-------Adding column with diastole or systole to behavioral data.----%
    % I need to find the row number and then the actual value for point for the 
    % corresponding ptc level etc.
    ptcp = i;                                                                   % participant 
    for set=min(behavioral_a.set):max(behavioral_a.set)                         % set 
        for row=min(behavioral_a.lvl):max(behavioral_a.lvl)                       % level !!!!!! I NEED TO DO SOMETHING REGARDING  
            try
            tool3 = find(behavioral_a.start(behavioral_a.ptcp==ptcp &...
                behavioral_a.lvl==row & behavioral_a.set==set,:) < tool2 &...
                tool2 < behavioral_a.end(behavioral_a.ptcp==ptcp &...
                behavioral_a.lvl==row & behavioral_a.set==set,:));

            behavioral_a.zyklus(behavioral_a.ptcp==ptcp &...
                behavioral_a.lvl==row & behavioral_a.set==set) = ...
                points.zyklus(points.row==tool2(tool3),:);
            catch
                if behavioral_a.stimulus(behavioral_a.ptcp==ptcp &...
                behavioral_a.lvl==row & behavioral_a.set==set)==3           %do nothing

                behavioral_a.zyklus(behavioral_a.ptcp==ptcp &...
                        behavioral_a.lvl==row & behavioral_a.set==set) = ...
                        "keine vibration";
                end
            end
        end
    end
    clear ans k ECG_vibration ptcp set tool2 tool3 vib vib_start
    catch ME
        fprintf('Level missing for participant %i , skipped.\n',...
                i)                                                          % algorithm from HEPLAB
        end
    end

clear fs gr i row 

%% ============== Saving New Matrix =======================================

writetable(behavioral_a,['/Users/calypso/Dropbox/'...
'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/'...
'P1_propioception/R_tsvr_presentation/data/zusammen.csv'])

