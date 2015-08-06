% a=1;
% b=sprintf('%3.3d',a)
% b = 001

clear all

directory = 'D:\LEMON\Data\LEMON_PTT';
origdir = 'D:\LEMON\Data\LSData_NEU';
%origdir = 'D:\LEMON\Data\BPround2';

%% create folders
% for isub = 1:171
%
%     sub = sprintf('%3.3d',isub);
%
%     [success] = mkdir(fullfile(directory, ['LEMON',sub]));
%
%     if success
%
%         display(['created folder for ','LEMON',sub])
%     else
%         display(['!!! Could not create folder for ','LEMON',sub])
%     end
% end

%% copy files
%
% for isub = 1:171
%
%     sub = sprintf('%3.3d',isub);
%
%     ecgfile = dir(fullfile(directory, ['LEMON',sub], '*.eeg'));
%     matfile = dir(fullfile(directory, ['LEMON',sub], '*.mat'));
%
%     if isempty(ecgfile)
%         % numecg = numecg + 1;
%
%         eeg = rdir(fullfile(origdir, ['\**\LEMON',sub, '*.eeg']));
%         mrk = rdir(fullfile(origdir, ['\**\LEMON',sub, '*.vmrk']));
%         hdr = rdir(fullfile(origdir, ['\**\LEMON',sub, '*.vhdr']));
%
%         if isempty(eeg)
%             display(['!!! did not find LEMON',sub, '*.eeg'])
%         else
%             [eegp,eegn,eegext] = fileparts(eeg.name);
%             [success1] = copyfile(eeg.name, fullfile(directory,['LEMON',sub], [eegn, '.eeg']));
%
%             if success1
%                 display(['copied ', eegn, '.eeg'])
%             else
%                 display(['!!! Could not copy ', eegn, '.eeg'])
%             end
%         end
%
%         if isempty(mrk)
%             display(['!!! did not find LEMON',sub, '*.vmrk'])
%         else
%             [success2] = copyfile(mrk.name, fullfile(directory,['LEMON',sub], [eegn, '.vmrk']));
%
%             if success2
%                 display(['copied ', eegn, '.vmrk'])
%             else
%                 display(['!!! Could not copy ', eegn, '.eeg'])
%             end
%         end
%
%         if isempty(hdr)
%             display(['!!! did not find LEMON',sub, '*.vhdr'])
%         else
%             [success3] = copyfile(hdr.name, fullfile(directory,['LEMON',sub], [eegn, '.vhdr']));
%
%             if success3
%                 display(['copied ', eegn, '.vhdr'])
%             else
%                 display(['!!! Could not copy ', eegn, '.eeg'])
%             end
%         end
%
%     end
%     if isempty(matfile)
%         %nummat = nummat + 1;
%
%         mat = rdir(fullfile(origdir, ['\**\LEMON',sub, '*BPP.mat']));
%
%         if isempty(mat)
%             display(['!!! did not find LEMON',sub, '*.mat'])
%         else
%             [matp,matn,matext] = fileparts(mat.name);
%             [success4] = copyfile(mat.name, fullfile(directory,['LEMON',sub], [matn, '.mat']));
%
%             if success4
%                 display(['copied ', matn, '.mat'])
%             else
%                 display(['!!! Could not copy ', matn, '.mat'])
%             end
%         end
%
%
%     end
%
%
%     %     subdir = dir(fullfile(origdir, ['LEMON',sub]));
%     %
%     %     if success
%     %
%     %         display(['created folder for ','LEMON',sub])
%     %     else
%     %         display(['!!! Could not create folder for ','LEMON',sub])
%     %     end
% end

%% check files
%
% for isub = 1:171
%
%     sub = sprintf('%3.3d',isub);
%
%     ecgfile = dir(fullfile(directory, ['LEMON',sub], '*.eeg'));
%
%     if isempty(ecgfile)
%         display(['!!! did not find LEMON',sub, '*.eeg'])
%     end
%
% end
% display([''])
% for isub = 1:171
%
%     sub = sprintf('%3.3d',isub);
%     matfile = dir(fullfile(directory, ['LEMON',sub], '*.mat'));
%
%     if isempty(matfile)
%         display(['!!! did not find LEMON',sub, '*.mat'])
%     end
%
% end

%% copy done files

done = [69:82,85,86,89,91:93,97,99,101,103,104,108:110,112,115];


for idone = 2:length(done)
    
 sub = sprintf('%3.3d',done(idone));
% %     mkdir(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output']));
% %     
try   
ecg = dir(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output'], '*ECG_peaks_auto.mat'));
    load(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output'], ecg.name))
    
    ibis = diff(savecg);
    
    loc_s1 = 1;
    
    % at which heartbeat have we reached the first/second/third 5 minutes?
    % while (oxy.locs_cropped(locox_s1) < 300000)
    while sum(ibis(1:loc_s1)) < 300000
        loc_s1 = loc_s1 + 1;
    end
    
    loc_s2 = loc_s1-1; % updated MG 24.5.15, was locox_s1
    
    while sum(ibis(loc_s1-1:loc_s2)) < 300000
        loc_s2 = loc_s2 + 1;
    end
    
    loc_s3 = loc_s2-1;  % updated MG 24.5.15, was loc_s2
    
    % while (oxy.locs_cropped(loc_s3) <= 900000)
    while sum(ibis(loc_s2-1:loc_s3)) < 300000
        loc_s3 = loc_s3 + 1;
    end
    
    ibis_s1 = ibis(1:loc_s1-1); % updated MG 24.5.15, was locox_s1
    ibis_s2 = ibis(loc_s1:loc_s2-1); % updated MG 24.5.15, was loc_s2
    ibis_s3 = ibis(loc_s2:loc_s3-1);
    
    dlmwrite(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output'],[ecg.name(1:12) '_tachogramm_ECG_s1.txt']),ibis_s1');
    dlmwrite(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output'],[ecg.name(1:12) '_tachogramm_ECG_s2.txt']),ibis_s2');
    dlmwrite(fullfile(directory,['LEMON', sub],['LEMON', sub, '_output'],[ecg.name(1:12) '_tachogramm_ECG_s3.txt']),ibis_s3');
    
end
% %     %     dirtmp = dir(fullfile(origdir, ['*LEMON', sub]));
% %     %     [success5] = copyfile(fullfile(origdir, dirtmp.name, [dirtmp.name, '_output']), fullfile(directory,['LEMON', sub]));
% %     %
% %     %     if success5
% %     %         display(['copied LEMON', sub, '_output'])
% %     %     else
% %     %         display(['!!! Could not copy LEMON', sub, '_output'])
% %     %     end
    
end