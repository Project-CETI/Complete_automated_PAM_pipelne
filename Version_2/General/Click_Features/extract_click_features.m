function Click_detections=extract_click_features(Click_detections)

    Click_detections.Pkk=zeros(1,length(Click_detections.ToAs));
    Click_detections.spectral=cell(1,length(Click_detections.ToAs)); 

    for F_index=1:length(Click_detections.ToAs)
        click_ROI=Click_detections.ROIs{F_index};
        Click_detections.Pkk(F_index)=max(click_ROI)-min(click_ROI);
        Y = fft(click_ROI);
        L=length(click_ROI);
        P2 = abs(Y/L);
        P1 = P2(int32(1):int32(L/2+1));
        P1(2:end-1) = 2*P1(2:end-1);
        Pm=movmean(P1,12); 
        Click_detections.spectral(F_index)={normalize(Pm)};    
    end

       
end

