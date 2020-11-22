%% Checking for congruent incongruent ammoun of trials or levels.
% 
% all = all2(15).data; % unactivated code for testing
% checking existing categories and removing excess. 
if size(categories(all.feedbackType),1)>3
    fileID = fopen('/Users/calypso/exp.txt','w');
    fprintf(fileID,['too many categories in ' ptcp ', removing excess categories \n']);
    fclose(fileID);
    all2(i).data.feedbackType = removecats(all.feedbackType);
    all.feedbackType = removecats(all.feedbackType);
    else    
end
clear fileID ans
% getting the number of observation feedtype per level.
a  = groupcounts(all,{'set', 'levelCounter', 'feedbackType'});
% k=find(a.feedbackType=='congruent') 
%% Labeling each level with one feedtype by aplying it to the maximun. 
% Getting file  list
%fl_ls = dir('/Users/calypso/Dropbox/data/tsvr06') ;
all_lvl = [];
for j=1:max(all.set)%size(all2,2)
    b = a(a.set==j,:); % this subset for set
    lvl = array2table([unique(b.levelCounter), zeros(max(b.levelCounter)+1,1)],'VariableNames',  {'level' 'stimulus'}); % this predefines the table we wannt to build 
    for r =min(b.levelCounter):max(b.levelCounter) % this make it go for every level. 
        opt = b(b.levelCounter == r,:); % this makes the instrumental varaibel only consider one set at a time
        if height(opt) > 1 % this allows to if there is more than one level to continue
            Idx = find(opt.GroupCount == max(opt.GroupCount),1);% this assigns the labels of the feedbacktype with the most observations to the complete level 
            lvl(r+1,2) = table(opt.feedbackType(Idx,:)); % this insert the value rescued from the previous step.
        else
        lvl(r+1,2) = table(opt.feedbackType);% this directly assign the only stimulus possible for the level
        end
    end
    c = [table(ones(max(b.levelCounter)+1,1)*j,'VariableNames',{'set'}) lvl];% this codes adds a first column with the set number
    all_lvl = [all_lvl; c];
end
% need to check still all_level is not empty.

clear  b c r j Idx lvl opt
%% getting level with problems 
%all_lvl = array2table(all_lvl);
%all_lvl.Properties.VariableNames = {'set', 'lvl', 'stimulus'};

for j= min(a.set):max(a.set)
    b = a(a.set==j,:); 
    sset = all_lvl(all_lvl.set==j,:);
    d = groupcounts(sset,'stimulus');
    if diff(d.GroupCount) ~= 0
        fprintf("Überprugungs tabbelle \n Different number of cases detected in set %d \n",j) %this shares a message that detected different levels 
        d
        for r = min(b.levelCounter):max(a.levelCounter)
            opt = b(b.levelCounter == r,:);
            if height(opt)>1 & abs(diff(opt.GroupCount)) < 400
                fprintf("Problem in level %d \n Difference under 400\n",r) ;
            elseif height(opt)>1 && sum(opt.GroupCount) > max(b.GroupCount)-0.1*max(b.GroupCount)
                fprintf("Problem in level %d \nSum over %d\n",r,max(a.GroupCount)-0.1*max(b.GroupCount));
            end
        end
    else
        fprintf("Alles gut \n Gleich Anzahl von Fällen an einstellen %d \n ",j)
        d
    end
end

clear d  b c Idx j sset r a opt
%% Looking into the problem (automatically fixing problems)
 
