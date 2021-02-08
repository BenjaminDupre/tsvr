%% ============== Preparing Behavioral file to to R =======================
tic
behavioral_a =[];
for i=1:size(all2,2)
    responsetime = all2(i).rtime.data;
    responsetime.ptcp = ones(size(all2(i).rtime.data,1),1)*i;
    behavioral_a = [behavioral_a;responsetime ];
end
%% ============== Adding mistakes =========================================
mistakes=[];                                                                % this creates intrumental matrix
mistakesf=[];                                                               % this creates goal matrix
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

clear responsetime i
%% ============== Saving New Matrix =======================================
writetable(behavioral_a,['/Users/calypso/Dropbox/'...
'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/'...
'P1_propioception/R_tsvr_presentation/data/responsetime.csv'])
toc