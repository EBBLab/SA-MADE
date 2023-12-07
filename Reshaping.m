%% Have to delete the prior csv files in the Reshpaed foler to be able to run this script

clear variables; close all; clc;
excelfile_path_and_name='Lorem ipsum';
folder_to_save='Lorem ipsum';
folder_to_save_log='Lorem ipsum';
[~,~,SS] = xlsread(excelfile_path_and_name);

SS(1,:)=[];
condition='_sResting';
%condition='_sResting_arm';
%condition='_MMN';
%condition='_VEP';


status=[];
pz_ID_vect_TOT=[];

for pz=1:size(SS,1)
    
    pz_temp=SS(pz,:);
    pz_ID_vect=pz_temp{1,1};
    
    pz_temp=pz_temp(1,2:end);
    pz_temp_nan = find(cell2mat(cellfun(@(x)any(isnan(x)),pz_temp,'UniformOutput',false)));
    pz_temp(pz_temp_nan)=[];
    
    pos_sec=1:size(pz_temp,2);
    pos_state=3:3:size(pz_temp,2);
    pos_sec(pos_state)=[];
    
    pz_starstop=pz_temp(pos_sec)';
    pz_SS=pz_temp(pos_state)';
    
    pz_SS_vect=[];
    for k=1:length(pz_SS)
        SS_temp=pz_SS(k);
        if strcmp(SS_temp, "I")
            pz_SS_vect=[pz_SS_vect; {'Istart'}; {'Iend'} ];
        else if strcmp(SS_temp, "W")
                pz_SS_vect=[pz_SS_vect; {'Wstart'}; {'Wend'} ];
            else if strcmp(SS_temp, "AS")
                    pz_SS_vect=[pz_SS_vect; {'ASstart'}; {'ASend'} ];
                else if strcmp(SS_temp, "QS")
                        pz_SS_vect=[pz_SS_vect; {'QSstart'}; {'QSend'} ];
                    else
                        pz_SS_vect=[pz_SS_vect; {'Istart'}; {'Iend'} ];
                    end
                end
            end
        end
    end
    
    
    excel_filename=char(strcat(string(pz_ID_vect), condition));
    excel_data=[pz_starstop, pz_SS_vect];
    
    if isempty(excel_data)
        continue
    end
    
    if ~isfile([folder_to_save, excel_filename, '.csv'])
        writecell(excel_data,[folder_to_save, excel_filename, '.csv'])
        disp([strcat(string(pz_ID_vect), condition) 'Processed']);
        status=[status; "Processed"];
    else
        [pz_starstop_check,pz_SS_vect_check,~] = xlsread([folder_to_save, excel_filename, '.csv']);
        if ~isequal(cell2mat(pz_starstop), pz_starstop_check) || ~isequal(pz_SS_vect, pz_SS_vect_check)
            delete([folder_to_save, excel_filename, '.csv'])
            writecell(excel_data,[folder_to_save, excel_filename, '.csv'])
            disp([strcat(string(pz_ID_vect), condition) 'Reprocessed']);
            status=[status; "Reprocessed"];
        else
            disp([strcat(string(pz_ID_vect), condition) 'Unchanged']);
            status=[status; "Unchanged"];
        end
    end
    
    pz_ID_vect_TOT=[pz_ID_vect_TOT; strcat(string(pz_ID_vect), condition)];
    
    clear pz_temp pz_temp_nan pos_sec pos_state pz_starstop pz_SS pz_SS_vect excel_filename excel_data pz_starstop_check pz_SS_vect_check
    
end

% t = string(datetime('now'));
log=[pz_ID_vect_TOT, status];
c = clock; c=round(fix(c)); 
t=strcat(string(c(1)), '_', string(c(2)), '_', string(c(3)), '_', string(c(4)), '_', string(c(5)), '_', string(c(6)));
writematrix(log,strcat(folder_to_save_log, strcat('log_', t, '.csv')));