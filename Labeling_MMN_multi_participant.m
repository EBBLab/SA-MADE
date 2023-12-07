% This script is called by the Filter_Faster_ICA_Adjust_Merged_ECHO_mergetest.m script 
%...and labels the MMN data
% first created on 10/17/18 ... last updated 05/27/2020

% We created list of the event files and their order. Loading in those lists:
markerinfo1 = xlsread([scripts_location 'MMN_Block1_TrialOrder.xlsx']);
markerinfo2 = xlsread([scripts_location 'MMN_Block2_TrialOrder.xlsx']);
markerinfo = [markerinfo1; markerinfo2]; % Concatenating the 2 blocks

% add task labels to the event structure
EEG = pop_editeventfield( EEG, 'indices',  strcat('1:', int2str(length(EEG.event))), 'PrevTone','NaN', 'NumOfPrevTone','NaN');
EEG = eeg_checkset( EEG );
                        
% stimEventNums=find(strcmp({EEG.event.type},'stm+'));
% LatFirst=(EEG.event(stimEventNums(1)).latency)/EEG.srate;

% pull out DIN2 information
DINSEventNums=find(strcmp({EEG.event.type},'DIN2'));
DINsnum = length(DINSEventNums);

% Checking that we always get the number of DINS we would expect. If not, error out.
%if length(DINSEventNums)~=800 || length(DINSEventNums)~=400
    % if we don't have exactly 1 or 2 blocks, skip this participant
    cd(output_location)
    fid = fopen('MMN_DIN_number.txt', 'a');
    fprintf(fid, '%d DINs, Subject = %s \r\n', DINsnum, datafile_names{s});
    fclose(fid);
%elseif length(DINSEventNums)==800 || length(DINSEventNums)==400
    sprintf('MMN looks good, labeling now')
    
%     % save out a table with event information
%     table_events = struct2table(EEG.event);
%     writetable(table_events, ['/export/data/cdl/Projects/ECHO/Descriptives/MMN_Check/', subject, '.csv'])
    
    standardCount=0; % preset at 0 before entering loop below
    % loop to re-label events per trial
    for t = 1:length(DINSEventNums) %t = EVENT numbers associated with each DIN2 (trial)
        % add labels to each trial in the event structure
        EEG.event(DINSEventNums(t)).type = markerinfo(t,2);
        EEG.event(DINSEventNums(t)).NumOfPrevTone = standardCount;
        
        % count how many standards in a row before Dev. or Novel tones
        if EEG.event(DINSEventNums(t)).type==1 % if standard tone
            standardCount = standardCount+1;
        else % if deviant or novel tone
            standardCount = 0; % reset at 0
        end
        
        if t ~= 1 && t ~= 401 % unless it is the first trial in the 2nd block, mark prev. tone
            EEG.event(DINSEventNums(t)).PrevTone = markerinfo(t-1,2);
        else % if it is the first trial in the 2nd block
            EEG.event(DINSEventNums(t)).NumOfPrevTone = 0;
        end
    end % end of loop through trials
%end % end check that number of DIN2 flags equals 1 or 2 blocks

