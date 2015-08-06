
function oxy = LEMON_LSD_PTT_oxy(subdir, showfi)

%% read oxy (PPG) data

oxy.dir =  subdir; %datadir;
biopac = dir(fullfile(subdir,'*.mat'));% detect MAT file in oxydir

oxy.file = biopac.name;
oxy.loader = load(fullfile(subdir, oxy.file));
oxy.sf = 1000;
oxy.data = oxy.loader.data(:,4);
oxy.atrig = find(oxy.loader.data(:,8)==5); % find Trigger


%----------- INSERTED 05.02.2015 because of odd TRs after first trigger

voldiffoxy = diff(oxy.atrig);
%voldiffoxy = voldiffoxy(voldiffoxy>1); % excl. 1
mostfrqoxy = 1400;% mode(voldiffoxy(voldiffoxy>1)); % find most frq.

oxy.onsetoxy = 1;

% if strcmp(datype,'LSD')
%
%     while sum(voldiffoxy(oxy.onsetoxy:oxy.onsetoxy+20)) - 2*mostfrqoxy > 3
%
%         %while sum(voldiffoxy(onset:onset+20)) > 2*mostfrqoxy
%         %while  ~(voldiffoxy(onset)-mostfrqoxy < 3 & voldiffoxy(onset+1)-mostfrqoxy < 3 & voldiffoxy(onset+2)-mostfrqoxy < 3)
%         oxy.onsetoxy = oxy.onsetoxy + 1;
%     end
%
%     %corr_onset = onset - 20; % correct for shift that was used to find onset
%
% else
while sum(voldiffoxy(oxy.onsetoxy:oxy.onsetoxy+7)) - mostfrqoxy > 15
    %while  ~(voldiffoxy(onset)-mostfrqoxy < 3 & voldiffoxy(onset+1)-mostfrqoxy < 3 & voldiffoxy(onset+2)-mostfrqoxy < 3)
    oxy.onsetoxy = oxy.onsetoxy + 1;
end
%corr_onset = onset - 20; % correct for shift that was used to find onset


% end

oxy.data = oxy.data(oxy.atrig(oxy.onsetoxy):end); % data = cropped [was oxy.atrig(1), MG 5.2.15]

%----------- end of insertion

oxy.t = 0:1/oxy.sf:length(oxy.data)/oxy.sf-1/oxy.sf; % time length???

% % detrend 
% [p,s,mu] = polyfit((1:numel(oxy.data))',oxy.data,6);
%         f_y = polyval(p,(1:numel(oxy.data))',[],mu);
%         
%         oxy.data_detrend = oxy.data - f_y;    
% 

oxy.zdata = zscore(oxy.data); % zscore, standardize

% low-pass filter

[b,a] = butter(3,[10]*2/oxy.sf,'low');
oxy.fzdata = filtfilt(b,a,oxy.zdata);


% resample %p/q time orig sf


%oxy.data_resampled = resample(oxy.fzdata,newSf,oxy.sf);
%oxy.t_resampled = 0:1/newSf:length(oxy.data_resampled)...
   % /newSf-1/newSf;

[oxy.peaks_uncropped,oxy.locs_uncropped] = findpeaks(oxy.fzdata,'minpeakdistance',.5*oxy.sf,'minpeakheight',.5);


if showfi
    figure
    subplot(1,2,1)
    plot(oxy.t,oxy.fzdata,'b',...
        oxy.t(oxy.locs_uncropped),oxy.peaks_uncropped,...
        'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    title([subdir(end-7:end), ' oxy - peak detection: ' num2str(length(oxy.locs_uncropped)) ' pks.'])
    hold
end


%% cropped peak detection

oxy.oxyphase = 1:912800; % 15 min = 912800 ms, more precisely: 652 * 1400 (TR)

oxy.data_cropped = oxy.data(oxy.oxyphase);
oxy.zdata_cropped = zscore(oxy.data_cropped); % zscore, standardize

oxy.t_zcropped = 0:1/oxy.sf:length(oxy.zdata_cropped)...
    /oxy.sf-1/oxy.sf;
oxy.t_zcropped_ms = oxy.t_zcropped*1000;

[oxy.peaks,oxy.locs] = findpeaks(oxy.zdata_cropped,'minpeakdistance',.5*oxy.sf,'minpeakheight',.5);

if showfi
    %figure
        subplot(1,2,2)

    plot(oxy.t_zcropped,oxy.zdata_cropped,'b',...
        oxy.t_zcropped(oxy.locs),oxy.peaks,...
        'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    title([subdir(end-7:end), ' oxy (cropped) - peak detection: ' num2str(length(oxy.peaks)) ' pks.'])
end

duration_m = length(oxy.t_zcropped)/60000;
duration_min = floor(length(oxy.t_zcropped)/60000);
duration_sec = round(60*(mod(length(oxy.t_zcropped),60000)/60000));

display(['found ', num2str(length(oxy.locs)), ' peaks in ' ...
    num2str(duration_min), ':' num2str(duration_sec), ' min; approx.: '...
    num2str(length(oxy.locs)/duration_m), ' bpm'])


oxy.t_ms_zcropped = oxy.t_zcropped*1000;

%% detect outliers
oxy.ibiso = diff(oxy.locs);

% if savefi
%     dlmwrite(fullfile(dirout,[dirs(idir).name '_tachogram_oxy.txt']),ibiso);
%     display(['saved raw OXY tachogram to file for subject ' dirs(idir).name]);
% end
if showfi
    figure, subplot(1,2,1), hist(oxy.ibiso,20), title('IBIs (oxy) - uncorrected'), hold on
end

% replace outliers (3 SD from mean)
m_ibio = mean(oxy.ibiso);
sd_ibio = std(oxy.ibiso);

ibout1o=oxy.ibiso>m_ibio+3*sd_ibio;
ibout2o=oxy.ibiso<m_ibio-3*sd_ibio;

down_out = find(ibout2o); %ibiso(ibout2o)
up_out = find(ibout1o); %ibiso(ibout1o)

% correct in timeline

% if corrflag
%     
%     oxy.locs_clean = oxy.locs;
%     
%     for iout = 1:length(down_out) % if too short, additional beat detected --> delete %%% NOT WORKING YET
%         
%         % oxy.locs_clean(end+1) = oxy.locs_clean(up_out(iout)+1)-(up_out(iout)/2);
%         oxy.locs_clean(end+1) = oxy.locs_clean(down_out(iout)+1)-m_ibio;
%         
%     end
%     
%     for iout = 1:length(up_out) % if too long, a beat not dected --> enter extra loc
%         
%         % oxy.locs_clean(end+1) = oxy.locs_clean(up_out(iout)+1)-(up_out(iout)/2);
%         oxy.locs_clean(end+1) = oxy.locs_clean(up_out(iout)+1)-m_ibio;
%         
%     end
%     
%     oxy.locs_clean = sort(oxy.locs_clean);
%     
%     
%     ibiso(ibout1o) = m_ibio;
%     ibiso(ibout2o) = m_ibio;
%     
%     if showfi
%         subplot(1,2,2), hist(ibiso,20), title(['IBIs (oxy) - ' num2str(sum(ibout1o)+sum(ibout2o)) ' corrected (\pm3 SD)']),
%     end
%     
% end
if showfi
    
    %     figure, plot(oxy.t_zcropped,oxy.zdata_cropped*400,'b',...
    %          oxy.t_zcropped(oxy.locs),oxy.peaks*400,...
    %         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    %     hold on
    %     plot(oxy.t_zcropped(oxy.locs(2:end)),ibiso, 'm', 'LineWidth',2)
    %     legend('oxy curve', 'oxy peaks', 'tachogram')
    %
    
    
    outliers = [down_out; up_out];
    oxy.outliers = sort(outliers);
    
    %     figure, plot(oxy.t_zcropped,oxy.zdata_cropped*400,'b',...
    %         oxy.t_zcropped(oxy.locs),oxy.peaks*400,...
    %         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    %     hold on
    %     plot(oxy.t_zcropped(oxy.locs(2:end)),ibiso, 'm', ...
    %         oxy.t_zcropped(oxy.locs(outliers)),oxy.peaks(outliers)*400,...
    %         'gv','MarkerFaceColor','g','MarkerSize', 12,'LineWidth', 2) % plot PPG, clean and downsampled
    %     %'LineWidth',2)
    %     legend('oxy curve', ['oxy peaks (' num2str(length(oxy.locs)) ')'], 'tachogram', [num2str(length(outliers)) ' detected outliers (\pm3SD)'])
    %
    
    
    figure, plot(oxy.t_zcropped,oxy.zdata_cropped*400,'b',...
        oxy.t_zcropped(oxy.locs),oxy.zdata_cropped(oxy.locs)*400,...
        'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
    hold on
    plot(oxy.t_zcropped(oxy.locs(2:end)),oxy.ibiso, 'm', ...
        oxy.t_zcropped(oxy.locs(outliers)),oxy.zdata_cropped(oxy.locs(outliers))*400,...
        'gv','MarkerFaceColor','g','MarkerSize', 12,'LineWidth', 2) % plot PPG, clean and downsampled
    %'LineWidth',2)
    legend('oxy curve', ['oxy peaks (' num2str(length(oxy.locs)) ')'], 'tachogram', [num2str(length(outliers)) ' detected outliers (\pm3SD)'])
    
    
end


%
% % ibiso_inv = cumsum(ibiso)+oxy.locs(1);
% %
% % figure, plot(oxy.locs_clean), hold on, plot(ibiso_inv, 'r')
% %
% % vals = ones(length(oxy.t_zcropped),1);
% %
% %   figure;
% %     plot(oxy.t_zcropped,oxy.zdata_cropped,'b',...
% %         oxy.t_zcropped(uint32(oxy.locs_clean)),oxy.zdata_cropped(uint32(oxy.locs_clean)),...
% %         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
% %     hold on
% %         plot(oxy.t_zcropped,oxy.zdata_cropped,'b',...
% %         oxy.t_zcropped(uint32(ibiso_inv)),oxy.zdata_cropped(uint32(ibiso_inv)),...
% %         'mv','MarkerFaceColor','m') % plot PPG, clean and downsampled
% %    % title([dirs(idir).name, ' oxy (cropped) - peak detection: ' num2str(length(oxy.peaks)) ' pks.'])
%
%
%

%
% if showfi
%
%     figure;
%     plot(oxy.t_zcropped,oxy.zdata_cropped,'b',...
%         oxy.t_zcropped(uint32(oxy.locs_clean)),oxy.zdata_cropped(uint32(oxy.locs_clean)),...
%         'rv','MarkerFaceColor','r') % plot PPG, clean and downsampled
%
%     title([dirs(idir).name, ' oxy (cropped) - peak detection: ' num2str(length(oxy.peaks)) ' pks.'])
%
% end

% DELTA=200;
%
% [oxy.peaks_qrs] = getqrs(oxy.zdata_cropped,oxy.t_zcropped_ms,DELTA)
%

end