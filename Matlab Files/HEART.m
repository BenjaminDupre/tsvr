%% Initilization

tic
fs=133;
gr=false;

%% ============== Loading Data ============================================
for hr=1:size(all2,2)
    ecg=table;
    ecg.ecg = all2(hr).data.ECG;
    ecg.ptcp(1:size(ecg,1)) = string(all2(hr).ptcp);
    ecg.set = all2(hr).data.set;
    ecg.lvl = all2(hr).data.levelCounter;
    ecg= ecg(:,[2:end 1]);
%     writetable(ecg ,append('/Users/calypso/Dropbox/',...
%     'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
%     'P1_propioception/R_tsvr_presentation/data/alles_hr/', 'hr',...
%     string(hr), '.csv'))  
%% ============== Detecting all parts of the heart cycle ==================
    try 
        ecg= ecg{:,4};
        [R,Q,S,T,P_w] = heplab_T_detect_MTEO(ecg,fs,gr);
        % 1.creating IBIS
      
        IBI = [R(:,1) [0; diff(R(:,1)/fs)]];
        [IBI, r] = rmoutliers(IBI);
        % 2. Selecting 2 seconds before the appearence of the ball and 2
        % seconds after the appearence of the ball & joining int with 
        % behavioral data 
        for i=1:size(behavioral_a(behavioral_a.ptcp==hr,:),1)
            try
                bb = behavioral_a(behavioral_a.ptcp==hr,:);
                behavioral_a.IBI(behavioral_a.ptcp==hr & ...
                    behavioral_a.set==bb.set(i) & ...
                    behavioral_a.lvl==bb.lvl(i)) = ...
                    mean(IBI(bb.start(i) ... %-fs*2
                <= IBI(:,1)& IBI(:,1) <= bb.start(i)+fs*1.5,2));
            
            catch
            fprintf('Level %i missing for participant %i , skipped.\n',...
                i, hr)
            continue;  % Jump to next iteration of: for i
            end
        end
        writematrix(R ,append('/Users/calypso/Dropbox/',...
        'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
        'P1_propioception/R_tsvr_presentation/data/alles_hr/', 'R',...
        string(hr), '.csv'))
        writematrix(T ,append('/Users/calypso/Dropbox/',...
        'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
        'P1_propioception/R_tsvr_presentation/data/alles_hr/', 'T',...
        string(hr), '.csv'))
    
    catch
        fprintf('Inconsistent data in iteration %i, skipped.\n', hr)
        continue
    end
end    
clear bb
%% ============== Defininig length of event  ==============================
writetable( behavioral_a,append('/Users/calypso/Dropbox/',...
        'My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/',...
        'P1_propioception/R_tsvr_presentation/data/alles_hr/', 'behavioral_a',...
         '.csv'))
toc


