function Slant_delays=Extract_slant_delays(test,Click_detections,P,Fs)

    M=2; Slant_delays=[];  
    for i=1:length(Click_detections.ToAs)
        if  (Click_detections.ToAs(i)+P.roi)*Fs<length(test)
            click_cand=test(int32((Click_detections.ToAs(i)-5e-3)*Fs):int32((Click_detections.ToAs(i)+P.roi)*Fs));
        else
            break;
        end
        Rxx=xcorr(click_cand,click_cand); 
        Rxx=abs(Rxx/max(Rxx));
        [p_ey,l_ey] =findpeaks(Rxx,Fs,'MinPeakDistance',2.5e-3);   
        [~,I_sort]=sort(p_ey,'descend');
        l_sort=l_ey(I_sort);
        l_chosen=l_sort(1:M);
        Slant_delays(i)=1e3*abs(diff(l_chosen));

    end
    
end