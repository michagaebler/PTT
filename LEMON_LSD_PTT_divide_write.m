function  LEMON_LSD_PTT_divide_write(ibis, dirout, subname, modality, showfi)


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

if showfi
    
    
    
    fig5min = figure;
    subplot(3,3,1);
    boxplot(ibis_s1);
    title([modality ' boxplot (1st 5min)'])
    subplot(3,3,2);
    hist(ibis_s1,20);
    title([modality ' histogram (1st 5min)'])
    subplot(3,3,3);
    plot(ibis_s1);
    title([modality ' 1st 5 min'])
    
    % figure,
    subplot(3,3,4);
    boxplot(ibis_s2);
    title([modality ' boxplot (2nd 5min)'])
    subplot(3,3,5);
    hist(ibis_s2,20);
    title([modality ' histogram (2nd 5min)'])
    subplot(3,3,6);
    plot(ibis_s2);
    title([modality ' 2nd 5 min'])
    
    % figure,
    subplot(3,3,7);
    boxplot(ibis_s3);
    title([modality ' boxplot (3rd 5min)'])
    subplot(3,3,8);
    hist(ibis_s3,20);
    title([modality ' histogram (3rd 5min)'])
    subplot(3,3,9);
    plot(ibis_s3);
    title([modality ' 3rd 5 min'])
    
    
    
    
end


saveas(fig5min, fullfile(dirout, [subname '_' modality '_split']), 'png')

if strcmp(modality, 'OXY')
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s1.txt']),ibis_s1);
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s2.txt']),ibis_s2);
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s3.txt']),ibis_s3);
elseif strcmp(modality, 'ECG')
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s1.txt']),ibis_s1');
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s2.txt']),ibis_s2');
    dlmwrite(fullfile(dirout,[subname '_tachogramm_' modality, '_s3.txt']),ibis_s3');
end

display([subname ': ' modality ' automatic tachograms cropped and written.'])





end