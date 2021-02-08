%% ======================= Building Response Time  ======================= 
% This script identifies the start and the end of the trail. It integreats 
% the start stop data with it with results from the Feedbacktype script and performs core  
% statistical inferences computationsfrom 
% proband=1 ;
% all = all2(proband).data;
run('/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/Data_Wrangling/Matlab Analysis/Data_Wrangling/feedbacktype_check.m')

%% ======================= Detecting Start of Stimmuli and Response Time. 
% for k = min(all.set):max(all.set)
% response time start (finding when the ball is placed in the hand). This
% means that the ball position goes grom its final position on the board
% into either the left or right hand. 
A = zeros(height(all)-1,1);
    for r = 1:height(all)-1                                                 % going through all observationthorugh one level
        A(r,1) = all.redBallPosition(r+1)~=all.redBallPosition(r);          % through one i the ball changes position. 
    end                                                                     % apparently because of the formulation I'm mmissing some part of level 35 change on red ball position. 

indx = find(A(:,1)==1);                                                     % getting row number for changes in ball position
ver = [array2table(indx) all(indx,'levelCounter') all(indx,'set')];         % merging row_start level_counter and set
  

start_t = array2table(zeros(max(all.levelCounter),3));                      %preallocating space
START1 = [];                                                                % building empty matrix
for k = min(all.set):max(all.set)                                           % 
    ver2=ver(ver.set==k,:);
    for j = min(ver2.levelCounter):max(ver2.levelCounter)
        F = ver2(ver2.levelCounter==j,'indx');                              % for every level consider the changes ball position only
        start_t(j+1,:) = [F(1,1) array2table(k) array2table(j)];            % for every level save the first change in ball position.
    end
    START1 = [START1 ;start_t];                                             % thi part puts all the starts for every set and level into one long table.
end

clear A r indx ver j k F ver2 start_t  
%% This seciton detects the end of the Trail per level.  
% There are two options  END1 which is the first change on template ball po
% sition or END2 which is the change of level. Apparantly up until this
% point there is 133 or 1 second difference between the, 
%
% Finding END1
%A = zeros(height(all)-1,1);
%tic
%for i = 1:height(all)-1 % going through all observationthorugh one level
%    A(i,1) = all.lastTemplateBallPosition(i+1)~=all.lastTemplateBallPosition(i);  % through one i the ball changes position. 
%    A(i,2) = all.set(i);
%    A(i,3) = all.levelCounter(i);
%end
%toc
%
%indx = find(A(:,1)==1); % getting row number for changes in lastTemplateBallPosition
%END1 = [indx A(indx,:)]; % merging row_start level_counter and set
% it misses and has changes reapeated. Looking for explosion alternative 

%% Finding END2
% This is the ending we finally opted for because when the board explotes
% is for sure when the trial ends and is not poluted by the push black
% button cases niether the if the ball felt from the board. The cases that
% participant drop the ball over the table and made into the board under 6
% seconds are not excluded. 
A = zeros(height(all)-1,1);
for r = 1:height(all)-1                                                     % going through all observationthorugh one level
    A(r,1) = all.levelCounter(r+1)~=all.levelCounter(r);                    % through one i the level changes
    % this conincides with  
    A(r,2) = all.set(r);                                                    % this adds the matrix the set value 
    A(r,3) = all.levelCounter(r);                                           % this adds to the matrix the level counter value
end
indx = find(A(:,1)==1);
END2 = array2table([indx A(indx,:); 0 0 0 0], 'VariableNames',{'id' 'TorF' 'set' 'lvl'});

clear A indx r 
%% Creating one table with starts and stops and feedbacktype and correct answers. 

bhv = [START1(:,2:3) END2(:,1) START1(:,1)];                                % this adds columns of start and end
bhv.diff = bhv{:,3} - bhv{:,4};                                             % this creates a diff column between start and end
bhv.diff = bhv.diff/133;                                                    % this getting diff column into seconds
bhv.Properties.VariableNames = {'set' 'lvl' 'end' 'start' 'diff'};          % this gives names to columns
bhv.stimulus = all_lvl.stimulus;                                            % this adds a column with feedBackType

bhv(bhv.diff <= 0 | bhv.diff > 6 ,:)=[];                                    % removing outliers 
B= bhv;                                                                     % creating instrumental varaible 

clear bhv all_lvl END2 START1
%% Statistical Inference 
% Here we are going to use none-parametric bootstrap tessting, then assuming
% gamma distributions we are going to test for parametric bootstrap
% distributions and finally we are going to apply normal t-test. 

r_time.data = B;
% figure('visible','off') 
% r_time.fig = stackedplot(B.diff); % this figure shows how the timediference evolves
% figure('visible','off')
% r_time.fig2 = boxplot(B.diff, B.stimulus); % this figure shows a boxplot for all three conditions. 
% 
% pd = fitdist(table2array(B(B.stimulus==3,5)),'gamma');%this fits ang gets parammaters of the distribution 
% [M] = gamstat(pd.a,pd.b); % this get the mean and the variance for our base condition
% % Runing a one sammple t-test that see whether the diference in times
% % between 2(incongruent) and 3(none) using 3 mean estimated as a gamma
% % distribution. 
% [h,p,ci,stats] = ttest(table2array(B(B.stimulus==2,5)),M,'Alpha',0.05); %this run the test
% r_time.t_inc = {h,p,ci,stats}; 
% % Runing a one sammple t-test that see whether the diference in times
% % between 1(congruent) and 3(none) using 3 mean estimated as a gamma
% % distribution. 
% [h,p,ci,stats] = ttest(table2array(B(B.stimulus==2,5)),M,'Alpha',0.05);
% r_time.t_cong = {h,p,ci,stats}; 

clear pd M h p ci stats