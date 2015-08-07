%% calculate HRV/PTT/PWV in 5 min windows of resting-state
% as collection of functions
% michael.gaebler@gmail.com
% 6.8.2015

clear all
close all;

datadir = fullfile('D:','LEMON','Data','LEMON_PTT');

dirs = dir(fullfile(datadir,'L*'));
% datadir(1) = fullfile(datadirtemp, 'LEMON');
% datadir(2) = fullfile(datadirtemp, 'LSD');

% SAMPLING FRQ.: resample %p/q time orig sf
% newSf = 50;

newSf = 1000;%500;

savefi = 1; % do you wanna save files? 1 = yes
showfi = 1;
corrflag = 0;

lemonsub = 21; % LEMON number

%sub = dir(fullfile(datadir,['*LEMON*', num2str(lemonsub)]));
sub.name = ['LEMON', sprintf('%3.3d',lemonsub)];


%idir = 74; % LSD

% oxyphase = 300000:600000; % 15 min = 900000 ms
% ecg_start = 218; % in marker (652 in total, 654 divisible by 3 = 218, 436)
% ecg_stop = 436;



display(['Analyzing data for subject ' sub.name])
% oxyphase = 1:300000; % 15 min = 900000 ms
% ecg_start = 1; % in marker (652 in total, 654 divisible by 3 = 218, 336)
% ecg_stop = 218;


if length(sub.name) < 7, datype = 'LSD'; else datype = 'LEMON'; end

dirout = fullfile(datadir,sub.name,[sub.name, '_output']);
if exist(dirout)~=7
    mkdir(dirout);
    display(['Created output folder for subject ' sub.name])
end
subdir = fullfile(datadir, sub.name);


%% OXY check

oxy = LEMON_LSD_PTT_oxy(subdir, showfi);


%% OXY split (segment OXY into 5-min snippets and write)
close all
LEMON_LSD_PTT_divide_write(oxy.ibiso, dirout, sub.name, 'OXY', showfi)

%% ECG check
% subdir = fullfile(datadir, sub.name);

ecg = LEMON_LSD_PTT_ecg(subdir, showfi);

%% ECG split (segment 5-min ECG snippets and write)
close all

LEMON_LSD_PTT_divide_write(ecg.ibisea, dirout, sub.name, 'ECG', showfi)


%% plot both peak detections (oxy and automatic ECG)

if showfi
    
    figure
    plot(ecg.t_resamp_ms,ecg.zdata_cropped_resamp,'b',...
        ecg.t_resamp_ms(ecg.locs),ecg.zdata_cropped_resamp(ecg.locs),...
        'rv','MarkerFaceColor','r','LineWidth',3,'MarkerSize',12) ,
    hold on;
    plot(oxy.t_ms_zcropped,oxy.zdata_cropped,'g',...
        oxy.t_ms_zcropped(oxy.locs),oxy.zdata_cropped(oxy.locs),...
        'mv','MarkerFaceColor','m','LineWidth',3,'MarkerSize',12)
    legend('ecg',['ecg pks (' num2str(length(ecg.locs)) ')'],...
        'oxy', ['oxy pks (' num2str(length(oxy.locs)) ')'])
    
    %datacursormode;
    %     figure;
    %     plot(ecg.t_ms_cropped_qrs,ecg.zdata_cropped_qrs_filt,'b',...
    %         ecg.t_ms_cropped_qrs(ecg.locs2),ecg.zdata_cropped_qrs_filt(ecg.locs2),...
    %         'rv','MarkerFaceColor','r','LineWidth',3,'MarkerSize',12) ,
    %     hold on;
    %     plot(oxy(idir).t_ms_zcropped,oxy(idir).zdata_cropped,'g',...
    %         oxy(idir).t_ms_zcropped(oxy(idir).locs_cropped),oxy(idir).peaks_cropped,...
    %         'mv','MarkerFaceColor','m','LineWidth',3,'MarkerSize',12)
    %     legend('ecg','ecg pks', 'oxy', 'oxy pks')
    %
    
end

%% PTT check!!!

ptt = LEMON_LSD_PTT_ptt(ecg, oxy, fullfile(datadir, sub.name), showfi);

%% divide AUTOMATIC PTT into 5-min snippets
% 5 min = 300 s = 300000 ms

loc_s1 = 1;

while sum(oxy.ibiso(1:loc_s1)) < 300000
    loc_s1 = loc_s1 + 1;
end

loc_s2 = loc_s1-1; % updated MG 24.5.15, was locox_s1

while sum(oxy.ibiso(loc_s1-1:loc_s2)) < 300000
    loc_s2 = loc_s2 + 1;
end

loc_s3 = loc_s2-1;  % updated MG 24.5.15, was loc_s2

% while (oxy.locs(loc_s3) <= 900000)
while sum(oxy.ibiso(loc_s2-1:loc_s3)) < 300000
    loc_s3 = loc_s3 + 1;
end

ptt_s1 = ptt(1:loc_s1-1);
ptt_s2 = ptt(loc_s1:loc_s2-1);
ptt_s3 = ptt(loc_s2:loc_s3-1);

if showfi
    figptt = figure;
    subplot(3,3,1), boxplot(ptt_s1), title('PTT boxplot (1st 5min)')
    subplot(3,3,2), hist(ptt_s1,20), title('PTT histogram (1st 5min)')
    subplot(3,3,3), plot(ptt_s1), title('PTT 1st 5 min')
    subplot(3,3,4), boxplot(ptt_s2), title('PTT boxplot (2nd 5min)')
    subplot(3,3,5), hist(ptt_s2,20), title('PTT histogram (2nd 5min)')
    subplot(3,3,6), plot(ptt_s2), title('PTT 2nd 5 min')
    subplot(3,3,7), boxplot(ptt_s3), title('PTT boxplot (3rd 5min)')
    subplot(3,3,8), hist(ptt_s3,20), title('PTT histogram (3rd 5min)')
    subplot(3,3,9), plot(ptt_s3), title('PTT 3rd 5 min')
end

if savefi
    saveas(figptt, fullfile(dirout, [sub.name '_PTT_split']), 'png')
    
    
    dlmwrite(fullfile(dirout,[sub.name '_ptt_s1.txt']),ptt_s1');
    dlmwrite(fullfile(dirout,[sub.name '_ptt_s2.txt']),ptt_s2');
    dlmwrite(fullfile(dirout,[sub.name '_ptt_s3.txt']),ptt_s3');
    
    display([sub.name ': PTT automatic tachograms cropped and written.'])
end

%% save variables
if savefi
    
    savecg = ecg.locs;
    save(fullfile(dirout,[sub.name '_ECG_peaks_auto']),'savecg');
    
    savoxy = oxy.locs;
    
    % save(fullfile(dirout,[dirs(idir).name '_ECG_peaks_manu']),'clean');
    %    save(fullfile(dirout,[sub.name '_ECG']),'ecg');
    
    save(fullfile(dirout,[sub.name '_OXY_peaks']),'savoxy');
    
    save(fullfile(dirout,[sub.name '_ptt']),'ptt');
    %save(fullfile(dirout,[dirs(idir).name '_PTT_manu']),'ptt_manu');
    display([sub.name ': ECG, OXY, and PTT saved.'])
    
    % inverse (load saved files)
    %     idir=1;
    %     ecg(idir).locs2 = savecg;
    %     oxy(idir).locs_cropped = savoxy;
    % clear sav*
    
end

%% EXTRA: introduce Blood pressure
subname = sub.name;
bp = LEMON_LSD_PTT_extra_BP(oxy, ecg, ptt, showfi, savefi, dirout, subname);
%close all