function ptt_auto = LEMON_LSD_PTT_ptt(ecg, oxy, subdir, showfi)

lenptt = min([length(ecg.locs),length(oxy.locs)]);

if ecg.locs(1) < oxy.locs(1)
    
    % just delete first oxy peak?
    
    for iloc = 1:lenptt % AUTOMATIC
        ptt_auto(iloc)  = oxy.locs(iloc) - ecg.locs(iloc);
    end
    
else
    for iloc = 1:lenptt-1 % AUTOMATIC
        ptt_auto(iloc)  = oxy.locs(iloc+1) - ecg.locs(iloc);
    end
end
%




% try to catch erroneous peaks
%
%
%     %corrfac = 0;
%     for iloc2 = 1:min([length(ecg.locs),length(oxy.locs)])%lenptt2 % AUTOMATIC
%
%         if oxy.locs(iloc2) < ecg.locs(iloc2+1)
%             ptt_auto(iloc2)  = (oxy.locs(iloc2) - ...
%                 ecg.locs(iloc2))*1000/newSf;
%
%         else
%             display(['something odd at peak ' num2str(iloc2) ', time ' num2str(oxy.locs(iloc2))])
%
%             %             ecg.locs(iloc2) = floor(mean([ecg.locs(iloc2-1),ecg.locs(iloc2+2)]));
%             %             ecg.locs(iloc2+1) = [];
%
%             break
%         end
%         %             %     if ptt_auto(iloc2) < 0
%         %             %         ptt_auto(iloc2)
%         %             %
%         %
%         %
%     end
%
%
% else
%     for iloc2 = 1:lenptt2 % AUTOMATIC
%
%         ptt_auto(iloc2)  = (oxy.locs(iloc2+1) - ecg.locs(iloc2))*1000/newSf;
%     end
%
%
% end

if showfi
    figure,
    subplot(1,3,1);
    boxplot(ptt_auto);
    title('PTT boxplot (full)')
    subplot(1,3,2);
    hist(ptt_auto,20);
    title('PTT histogram (full)')
    subplot(1,3,3);
    plot(ptt_auto);
    title('PTT tachogram (full)')
    
    
    
end



end