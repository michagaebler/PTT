clear all
close all;

datadir = fullfile('D:','LEMON','Data','LSData_NEU');

dirs = dir(fullfile(datadir,'L*'));

both = [69:78, 81, 85, 86, 91:93, 97, 99, 101, 103, 104, 108:110, 115];

correl = [];

for iboth = 1:length(both)
    
    sub = dir(fullfile(datadir,['*LEMON*', num2str(both(iboth))]));
    
    subdir = fullfile(datadir, sub.name, [sub.name, '_output']);
    
    load(fullfile(subdir,[sub.name, '_ECG_peaks_auto.mat']))
    
    tachoecg = diff(savecg);
    
    load(fullfile(subdir,[sub.name, '_OXY_peaks.mat']))
    
    tachoxy = diff(savoxy)';
    
    leng = min(length(tachoxy), length(tachoecg));
    
    [R, P] = corrcoef(tachoecg(1:leng), tachoxy(1:leng));
   
    subplot(5,5,iboth), scatter(tachoecg(1:leng), tachoxy(1:leng)), ...
        title([sub.name, ': r = ', num2str(R(1,2)), '; p = ', num2str(P(1,2))])
    correl = [correl; R(1,2),P(1,2)];
    
end