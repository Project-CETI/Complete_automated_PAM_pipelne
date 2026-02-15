function Click_detections=Extract_slant_delays(test,Click_detections,P,Fs)

    Click_detections.Slant_delays=zeros(1,length(Click_detections.ToAs));
    Click_detections.ROIs=cell(1,length(Click_detections.ToAs)); 
    All_ROIs=cell(1,length(Click_detections.ToAs));    

    for i=1:length(Click_detections.ToAs)
        if  (Click_detections.ToAs(i)+P.reflection_window(2))*Fs<length(test)
            click_cand=test(int32((Click_detections.ToAs(i)-P.reflection_window(1))*Fs):int32((Click_detections.ToAs(i)+P.reflection_window(2))*Fs));
            ROI=test(int32((Click_detections.ToAs(i)-P.roi)*Fs):int32((Click_detections.ToAs(i)+P.roi)*Fs));
            ROI_length(i)=length(ROI);
        else
            break;
        end
        Rxx=xcorr(click_cand,click_cand); 
        Rxx=abs(Rxx/max(Rxx));
        [p_ey,l_ey] =findpeaks(Rxx,Fs,'MinPeakDistance',P.min_slant_delay);   
        [~,I_sort]=sort(p_ey,'descend');
        l_sort=l_ey(I_sort);
        l_chosen=l_sort(1:P.M);
        Click_detections.Slant_delays(i)=1e3*abs(diff(l_chosen));
        All_ROIs(i)={ROI};      
    end

    Min_ROI_length=min(ROI_length);
    
    for i=1:length(ROI_length)
         roi_iter=All_ROIs{i};
         Click_detections.ROIs(i)={roi_iter(1:Min_ROI_length)};
    end

    if length(ROI_length)<length(Click_detections.ToAs)
        Click_detections.ToAs(length(ROI_length):end)=[];
        Click_detections.Amps(length(ROI_length):end)=[];
        Click_detections.Slant_delays(length(ROI_length):end)=[];
        Click_detections.ROIs(length(ROI_length):end)=[];
    end
    
end