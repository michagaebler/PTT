function bp = LEMON_LSD_PTT_extra_BP(oxy, ecg, ptt, showfi, savefi, dirout, subname)



%% BLOOD PRESSURE DATA (updated 26.2.2015 MG)

% find trigger peaks (because there are 10 data points per trigger)
%[trigpeaks,triglocs] = findpeaks(oxy.loader.data(:,8),'minpeakdistance',20,'minpeakheight',4); % tweak peak detection



% import blood pressure data

bp.data_sys_tmp = oxy.loader.data(oxy.atrig(oxy.onsetoxy):end,1); % erste 15 minuten snippet - 915585 datapts / ms
bp.data_sys = bp.data_sys_tmp(oxy.oxyphase); % erste 15 minuten snippet - 915585 datapts / ms

bp.data_dia_tmp = oxy.loader.data(oxy.atrig(oxy.onsetoxy):end,2); % erste 15 minuten snippet - 915585 datapts / ms
bp.data_dia = bp.data_dia_tmp(oxy.oxyphase); % erste 15 minuten snippet - 915585 datapts / ms

%bp.data_sys = oxy.loader.data(triglocs(1):triglocs(655),1); % erste 15 minuten snippet - 915585 datapts / ms
%bp.data_dia = oxy.loader.data(triglocs(1):triglocs(655),2); % erste 15 minuten snippet

if showfi
    
    figbp = figure; subplot(1,2,1), plot(bp.data_sys), hold on
    
end

% sd_sys = std(bp.data_sys(bp.data_sys>100));
% m_sys = mean(bp.data_sys(bp.data_sys>100));
%


% clean BP from outliers --> _np = non-parametric
m_sys = mean(bp.data_sys);
sd_sys = std(bp.data_sys);


med_sys = median(bp.data_sys);
mad_sys = mad(bp.data_sys);


display(['SD of BPsys: ' num2str(sd_sys)])
display(['MAD of BPsys: ' num2str(mad_sys)])



sysout1 = bp.data_sys>m_sys+3*sd_sys;
sysout2 = bp.data_sys<m_sys-3*sd_sys;

sysout1_np = bp.data_sys>med_sys+3*mad_sys;
sysout2_np = bp.data_sys<med_sys-3*mad_sys;


up_outbs = find(sysout1); %bp.data_sys(sysout1)
down_outbs = find(sysout2); %bp.data_sys(sysout1)

up_outbs_np = find(sysout1_np); %bp.data_sys(sysout1)
down_outbs_np = find(sysout2_np); %bp.data_sys(sysout1)

% higher or lower than 3 std becomes overall mean
bp.data_sys_clean = bp.data_sys;
bp.data_sys_clean(sysout1) = m_sys;
bp.data_sys_clean(sysout2) = m_sys;

bp.data_sys_clean_np = bp.data_sys;
bp.data_sys_clean_np(sysout1_np) = med_sys;
bp.data_sys_clean_np(sysout2_np) = med_sys;



%
% bp.data_sys(sysout1) = [];
% bp.data_sys(sysout2) = [];
% ptt(sysout1) = [];
% ptt(sysout2) = [];



if showfi
    plot(bp.data_sys_clean,'r'), title(['systolic BP - red: ' num2str(sum(sysout1)+sum(sysout2)) ' data pts corrected w/ mean (\pm3SD)']), hold on
    plot(bp.data_sys_clean_np,'g'), title(['systolic BP - green: ' num2str(sum(sysout1_np)+sum(sysout2_np)) ' data pts corrected /w median (\pm3MAD)'])

    %figure,     
    subplot(1,2,2),
plot(bp.data_dia), hold on
    
end

bp.sys_corrected = sum(sysout1)+sum(sysout2);
bp.sys_corrected_np = sum(sysout1_np)+sum(sysout2_np);


% clean data BP DIA
m_dia = mean(bp.data_dia);
sd_dia = std(bp.data_dia);

med_dia = median(bp.data_dia);
mad_dia = mad(bp.data_dia);

display(['SD of BPdia: ' num2str(sd_dia)])
display(['MAD of BPdia: ' num2str(mad_dia)])





diaout1 = bp.data_dia>m_dia+3*sd_dia;
diaout2 = bp.data_dia<m_dia-3*sd_dia;

diaout1_np = bp.data_dia>med_dia+3*mad_dia;
diaout2_np = bp.data_dia<med_dia-3*mad_dia;


up_outbd = find(diaout1); %bp.data_dia(diaout1)
down_outbd = find(diaout2); %bp.data_dia(diaout1)

up_outbd_np = find(diaout1_np); %bp.data_dia(diaout1)
down_outbd_np = find(diaout2_np); %bp.data_dia(diaout1)

% higher or lower than 3 std becomes overall mean
bp.data_dia_clean = bp.data_dia;
bp.data_dia_clean(diaout1) = m_dia;
bp.data_dia_clean(diaout2) = m_dia;

bp.data_dia_clean_np = bp.data_dia;
bp.data_dia_clean_np(diaout1_np) = med_dia;
bp.data_dia_clean_np(diaout2_np) = med_dia;

if showfi

    plot(bp.data_dia_clean,'r'), title(['diastolic BP - red: ' num2str(sum(diaout1)+sum(diaout2)) ' data pts corrected (\pm3SD)']), hold on
        plot(bp.data_dia_clean_np,'g'), title(['diastolic BP - green: ' num2str(sum(diaout1_np)+sum(diaout2_np)) ' data pts corrected /w median (\pm3MAD)'])

end

bp.dia_corrected = sum(diaout1)+sum(diaout2);
bp.dia_corrected_np = sum(diaout1_np)+sum(diaout2_np);


%
% [RHOs, PVALs] = corr(bp.data_sys(oxy.locs(1:580)),ptt(1:580)');
% [RHOd, PVALd] = corr(bp.data_dia(oxy.locs(1:580)),ptt(1:580)');
%
%
%
%     figure
%     subplot(2,1,1);
%     scatter(bp.data_sys(oxy.locs(1:580)),ptt(1:580)')
%     title([ecg.name(1:end-4) '; correlation systolic BP and PTT: rho = ' num2str(RHOs) ', p = ' num2str(PVALs)])
%     xlabel('systolic BP'), ylabel('PTT'),
%     lsline
%     subplot(2,1,2);
%     scatter(bp.data_dia(oxy.locs(1:580)),ptt(1:580)')
%     title([ecg.name(1:end-4) '; correlation diastolic BP and PTT: rho = ' num2str(RHOd) ', p = ' num2str(PVALd)])
%     xlabel('diastolic BP'), ylabel('PTT')
%     lsline

if savefi   
    saveas(figbp, fullfile(dirout, [subname '_BP_corrected']), 'png')  
end


%% CORRELATE ptt


[RHOs, PVALs] = corr(bp.data_sys_clean_np(oxy.locs(1:length(ptt))),ptt');
[RHOd, PVALd] = corr(bp.data_dia_clean_np(oxy.locs(1:length(ptt))),ptt');


% [RHOs, PVALs] = corr(bp.data_sys_clean_np(oxy.locs(1:lenptt)),ptt');
% [RHOd, PVALd] = corr(bp.data_dia_clean_np(oxy.locs(1:lenptt)),ptt');
% [RHOs, PVALs] = corr(bp.data_sys_clean_np(oxy.locs(1:875)),ptt');
% [RHOd, PVALd] = corr(bp.data_dia_clean_np(oxy.locs(1:875)),ptt');

if showfi
    
    figpttbp = figure;
    subplot(2,1,1);
    scatter(bp.data_sys_clean_np(oxy.locs(1:length(ptt))),ptt')
    title([ecg.name(1:end-4) '; correlation systolic BP and PTT: Pearson r = ' num2str(RHOs) ', p = ' num2str(PVALs)])
    xlabel('systolic BP'), ylabel('PTT'),
    lsline
    subplot(2,1,2);
    scatter(bp.data_dia_clean_np(oxy.locs(1:length(ptt))),ptt')
    title([ecg.name(1:end-4) '; correlation diastolic BP and PTT: Pearson r = ' num2str(RHOd) ', p = ' num2str(PVALd)])
    xlabel('diastolic BP'), ylabel('PTT')
    lsline
    
end

if savefi   
    saveas(figpttbp, fullfile(dirout, [subname '_PTT_BP_correl']), 'png')  
end


%% OXY IBIs and BP

[RHOis, PVALis] = corr(bp.data_sys_clean_np(oxy.locs(1:length(oxy.ibiso))),oxy.ibiso);
[RHOid, PVALid] = corr(bp.data_dia_clean_np(oxy.locs(1:length(oxy.ibiso))),oxy.ibiso);
% [RHOs, PVALs] = corr(bp.data_sys_clean_np(oxy.locs(1:875)),ptt');
% [RHOd, PVALd] = corr(bp.data_dia_clean_np(oxy.locs(1:875)),ptt');

if showfi
    
    figoxybp = figure;
    subplot(2,1,1);
    scatter(bp.data_sys_clean_np(oxy.locs(1:length(oxy.ibiso))),oxy.ibiso)
    title([ecg.name(1:end-4) '; correlation systolic BP and IBIoxy: Pearson r = ' num2str(RHOis) ', p = ' num2str(PVALis)])
    xlabel('systolic BP'), ylabel('IBI_oxy'),
    lsline
    subplot(2,1,2);
    scatter(bp.data_dia_clean_np(oxy.locs(1:length(oxy.ibiso))),oxy.ibiso)
    title([ecg.name(1:end-4) '; correlation diastolic BP and IBIoxy: Pearson r = ' num2str(RHOid) ', p = ' num2str(PVALid)])
    xlabel('diastolic BP'), ylabel('IBI_oxy')
    lsline
    
end

if savefi   
    saveas(figoxybp, fullfile(dirout, [subname '_OXY_BP_correl']), 'png')  
end

%% ptt and OXY IBIs

[RHO2, PVAL2] = corr(ptt(1:end-1)',oxy.ibiso(1:length(ptt)-1));
% [RHOs, PVALs] = corr(bp.data_sys_clean_np(oxy.locs(1:875)),ptt');
% [RHOd, PVALd] = corr(bp.data_dia_clean_np(oxy.locs(1:875)),ptt');

if showfi
    
    
    figoxyptt = figure;
    scatter(ptt(1:end-1)',oxy.ibiso(1:length(ptt)-1))
    title([ecg.name(1:end-4) '; correlation PTT and IBIoxy: Pearson r = ' num2str(RHO2) ', p = ' num2str(PVAL2)])
    xlabel('PTT'), ylabel('IBI_oxy'),
    lsline
    
    
end

if savefi   
    saveas(figoxyptt, fullfile(dirout, [subname '_OXY_PTT_correl']), 'png')  
end

end