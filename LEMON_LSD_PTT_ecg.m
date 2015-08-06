
function ecg = LEMON_LSD_PTT_ecg(subdir, showfi)



%%

ecg_start = 1; % start marker
ecg_stop = 657; % stop marker

newSf = 1000;
%% add ECG data - only first resting-state session

ecg.dir = subdir;

brainproducts = dir(fullfile(ecg.dir, '*.eeg'));

cd(subdir) % springe ins Datenverzeichnis


%for ifile = 1:length(brainproducts)

ecg.name = brainproducts.name;



%[path, name, ext] = fileparts(fullfile(datadir, brainproducts.name)); % Aufdröseln der Dateinamen
% try
    [ecg.data,ecg.sf,ecg.elab,ecg.marker] = gradcorr(ecg.name(1:end-4),'R128',1); % correct ECG (updated gradcorr)
    
    %test=readGenericEEG_raw2(ecg.name(1:end-4),1,'raw');
    
    
    %[ecg.data,ecg.sf,ecg.elab] = gradcorr_v2(ecg.name(1:end-4),'R128',1); % correct ECG (updated gradcorr)
    
% catch
%      [ecg.data,ecg.sf,ecg.elab,ecg.marker] = ...
%      gradcorr_ot_mg(ecg.name(1:end-4),1400,1); % correct ECG (updated gradcorr) NO TRIGGER VERSION
% end

%

%%%%%%% OLD CROP
%ecg.data_cropped = -ecg.data(ecg.marker(ecg_start,1):ecg.marker(ecg_stop,1));



%%%%%%%% NEW CROP: crop preceding sequences (EPI test?, quin pilot?)


voldiff = diff(ecg.marker);
mostfrq = mode(voldiff);

onset = 1;
while  ~(voldiff(onset)-mostfrq < 3 & voldiff(onset+1)-mostfrq < 3 & voldiff(onset+2)-mostfrq < 3)
    onset = onset + 1;
end

% ecg.data_cropped = -ecg.data(ecg.marker(onset,1):ecg.marker(ecg_stop,1)); % changed

ecg.data_cropped = -ecg.data(ecg.marker(onset,1):ecg.marker((onset + ecg_stop)-1,1)); % changed 2.2.2015 MG

% ecg.data_cropped = ...
% -ecg.data(ecg.marker(onset):ecg.marker((onset + ecg_stop)-1));
% % % crop when there are no triggers

% figure, plot(ecg.data_cropped)
%
% [p,s,mu] = polyfit((1:numel(ecg.data_cropped))',ecg.data_cropped,6);
% f_y = polyval(p,(1:numel(ecg.data_cropped))',[],mu);
%
% ECG_data = noisyECG_withTrend - f_y;        % Detrend data
%

% test=mean(ecg.data_cropped(ecg.data_cropped<1000));
%
% ecg.data_cropped(ecg.data_cropped>1000) = test;
% ecg.data_cropped(ecg.data_cropped<-1000) = test;

ecg.zdata_cropped = zscore(ecg.data_cropped); % zscored

% % % % low-pass filter - auf keinen Fall mit diesen Parametern - verschlechtert
% % % % Daten
% % % [b,a] = butter(3,[10]*2/ecg(ifile).sf,'low');
% % % ecg(ifile).fzdata_cropped = filtfilt(b,a,ecg(ifile).zdata_cropped);


ecg.zdata_cropped_resamp = resample(ecg.zdata_cropped,newSf,ecg.sf); % resample


ecg.t_resampled = 0:1/newSf:length(ecg.zdata_cropped_resamp)...
    /newSf-1/newSf;
ecg.t_resamp_ms = ecg.t_resampled*1000;


%[ecg.peaks,ecg.locs] = findpeaks(ecg.zdata_cropped_resamp,'minpeakdistance',.5*newSf);

%%
% ANPASSEN

[ecg.peaks,ecg.locs] = findpeaks(ecg.zdata_cropped_resamp,'minpeakdistance',.5*newSf,'minpeakheight',1);%.3)%1); % tweak peak detection
%[ecg.peaks,ecg.locs] = findpeaks(ecg.zdata_cropped_resamp,'minpeakdistance',900);%,'minpeakheight',1);%.3)%1); % tweak peak detection

%[ecg.peaks3,ecg.locs3] = findpeaks(ecg.zdata_cropped_resamp,'minpeakdistance',.5*newSf); % tweak peak detection



%     display([sprintf('%.1d',length(ecg(ifile).t_resampled)*20/60000) ' min of ECG data loaded and corrected for ', ...
%         ecg(ifile).name(1:end-4)])
duration_m = ecg.t_resampled(end)/60;
duration_min = floor(ecg.t_resampled(end)/60);
duration_sec = round((ecg.t_resampled(end)/60-duration_min)*60);

display([num2str(duration_m) ':' duration_sec ' min of ECG data loaded and corrected for ', ...
    ecg.name(1:end-4)])
display(['found ', num2str(length(ecg.locs)), ' peaks; approx. ' num2str(length(ecg.locs)/duration_m), ' bpm.'])




% ecg.data_cropped_resamp = resample(ecg.data_cropped,newSf,ecg.sf); % resample

%  dlmwrite(fullfile(dirout,[dirs(idir).name '_tachogramm_ecga_alltogether.txt']),ecg.data_cropped_resamp');



% ecg.data_cropped_qrs = resample(ecg.data_cropped,newSf,ecg.sf); % resample
%
% ecg.t_ms_cropped_qrs = (0:1/newSf:length(ecg.data_cropped_qrs)/newSf-1/newSf)*1000;
%


% [b,a] = butter(3,[10]*2/newSf,'low');
% ecg.data_cropped_qrs_filt = filtfilt(b,a,ecg.data_cropped_qrs);
%
% ecg.zdata_cropped_qrs_filt = zscore(ecg.data_cropped_qrs_filt);

%% MANUAL
%
% DELTA=200;
% %[clean] = getqrs(ecg(idir).data_cropped_qrs',ecg(idir).t_ms_cropped_qrs',DELTA)
% [clean] = getqrs(ecg.zdata_cropped_resamp',ecg.t_resamp_ms',DELTA)
%
% %         'a'  = add timepoint
% %         'r'  = reject timepoint
% %         'n' = step forward through data
% %         'q' = quit & exit w/o saving
% %         'f' = finish & save
%


%%
ecg.ibisea = diff(ecg.locs);

% if savefi
%     dlmwrite(fullfile(dirout,[dirs(idir).name '_tachogram_ecg_auto.txt']),ibisea');
%     display(['saved raw ECG tachogram (auto) to file for subject ' dirs(idir).name]);
% end


m_ibia = mean(ecg.ibisea);
sd_ibia = std(ecg.ibisea);

ibout1a=ecg.ibisea>m_ibia+3*sd_ibia;
ibout2a=ecg.ibisea<m_ibia-3*sd_ibia;

down_outa = find(ibout2a); %ibisea(ibout2a)
up_outa = find(ibout1a); %ibisea(ibout1a)


%
if showfi
    
    %     figure, plot(oxy.t_zcropped,oxy.zdata_cropped*400,'b',...
    %          oxy.t_zcropped(oxy.locs_cropped),oxy.peaks_cropped*400,...
    %         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    %     hold on
    %     plot(oxy.t_zcropped(oxy.locs_cropped(2:end)),ibiso, 'm', 'LineWidth',2)
    %     legend('oxy curve', 'oxy peaks', 'tachogram')
    %
    
    outliersa = [down_outa, up_outa];
    ecg.outliers = sort(outliersa);
    %     figure,   plot(ecg.t_ms_cropped_qrs,ecg.zdata_cropped_qrs_filt*300,'b',...
    %         ecg.t_ms_cropped_qrs(ecg.locs),ecg.zdata_cropped_qrs_filt(ecg.locs)*300,...
    %         'rv','MarkerFaceColor','r')
    %     hold on
    %     plot(ecg.t_ms_cropped_qrs(ecg.locs(2:end)),ibisea, 'm', ...
    %         ecg.t_ms_cropped_qrs(ecg.locs(outliersa)),abs(ecg.zdata_cropped_qrs_filt(ecg.locs(outliersa))*300),...
    %         'gv','MarkerFaceColor','g','MarkerSize', 12,'LineWidth', 2) % plot PPG, clean and downsampled
    %     %'LineWidth',2)
    %     legend('ecg curve', 'ecg auto peaks', 'tachogram', [num2str(length(outliersa)) ' detected outliers (\pm3SD)'])
    %
    %
    figure,   plot(ecg.t_resamp_ms,ecg.zdata_cropped_resamp*300,'b',...
        ecg.t_resamp_ms(ecg.locs),ecg.zdata_cropped_resamp(ecg.locs)*300,...
        'rv','MarkerFaceColor','r')
    hold on
    plot(ecg.t_resamp_ms(ecg.locs(2:end)),ecg.ibisea, 'm', ...
        ecg.t_resamp_ms(ecg.locs(ecg.outliers)),abs(ecg.zdata_cropped_resamp(ecg.locs(ecg.outliers))*300),...
        'gv','MarkerFaceColor','g','MarkerSize', 12,'LineWidth', 2) % plot PPG, clean and downsampled
    %'LineWidth',2)
    legend('ecg curve', 'ecg auto peaks', 'tachogram', [num2str(length(ecg.outliers)) ' detected outliers (\pm3SD)'])
    
    
    
    %
    %     figure, plot(oxy.t_zcropped,oxy.zdata_cropped*400,'b',...
    %          oxy.t_zcropped(oxy.locs_cropped),oxy.peaks_cropped*400,...
    %         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    %     hold on
    %     plot(oxy.t_zcropped(oxy.locs_cropped(2:end)),ibiso, 'm', ...
    %     oxy.t_zcropped(oxy.locs_cropped(outliersa)),oxy.peaks_cropped(outliersa)*400,...
    %         'gv','MarkerFaceColor','g','MarkerSize', 12,'LineWidth', 2) % plot PPG, clean and downsampled
    %     %'LineWidth',2)
    %     legend('oxy curve', 'oxy peaks', 'tachogram', 'detected outliers')
    
    
end
