function Detections=run_subtrain_detect(Sig,Click_detections,P,Fs,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2025
%   DESCRIPTION:

% This function provides click separation within buffers. The function gets
% a long audio and divides it into short time buffers and perform source assignment of identified clicks within each buffer.
% This separation is performed by clustering the clicks using a linear assinment (LA) approach.

% The output of this function is a sturct containing the clicks' attributes
% of each source in each buffer

%   INPUT:
%   > P.roi             - Scalar: region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
%   > F_weights         - Vector of 1X4 with the weights given to the attributes of classes 1-4 based on their relative information gain.
%   > P.Buffer_length   - Scalar: Analysis buffer length [sec]
%   > Sig               - Vector reprsenting a band-passed signal
%   > Fs                - Scalar: smpale rate of the signal 
%   > All_objs          - struct of 1X5 containing the GMM parameters of the clicks' similarity attributes
%   > Plot_flag         - Flag for visualizing results

%   OUTPUT:
%   > Detections         - Sturct containing the clicks' attributes of each source in each buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    t_index=0;
    t1=-P.Buffer_length;
    t2=0;        

    if Plot_flag.Click_separation
        t_sig=(0:1/Fs: (1/Fs)*(length(Sig)-1))';
        figure;
        subplot(2,2,1); plot(t_sig,Sig); hold on; grid on;
    end

    while(1)               
        t1=t1+P.Buffer_length;
        t2=t2+P.Buffer_length;
        t_index=t_index+1;
        if t2*Fs>length(Sig)
            break;
        end
        
        buffer_indices=Click_detections.ToAs>t1 & Click_detections.ToAs<t2;
        Clicks_within_buffer.ToAs=Click_detections.ToAs(buffer_indices);
        Clicks_within_buffer.Amps=Click_detections.Amps(buffer_indices);
        Clicks_within_buffer.whale_bearing=Click_detections.whale_bearing(buffer_indices);
        Clicks_within_buffer.whale_elevation=Click_detections.whale_elevation(buffer_indices);
        Clicks_within_buffer.ROIs=Click_detections.ROIs(buffer_indices);
        Clicks_within_buffer.Pkk=Click_detections.Pkk(buffer_indices);
        Clicks_within_buffer.spectral=Click_detections.spectral(buffer_indices);

        if length(Clicks_within_buffer.ToAs)>P.transients_threshold
            Detected_subtrains=Separation_within_buffer(Clicks_within_buffer,P);
        else
            Detected_subtrains={};
        end

        %% Remove click groups with unstable AoA
        Azi=Clicks_within_buffer.whale_bearing;
        Ele=Clicks_within_buffer.whale_elevation;
        Var=zeros(1,length(Detected_subtrains));
        for i=1:length(Detected_subtrains)
             subtrain_idx=Detected_subtrains{i};
             [~,TFrm] = rmoutliers(Azi(subtrain_idx)); Azi(subtrain_idx(TFrm))=median(Azi(subtrain_idx));
             [~,TFrm] = rmoutliers(Ele(subtrain_idx)); Ele(subtrain_idx(TFrm))=median(Ele(subtrain_idx));       
             Var(i)=mean(std([Azi(subtrain_idx)' Ele(subtrain_idx)']));
        end
        Include=Var<P.angle_variance;
        final_subtrains=Detected_subtrains(Include);

        if Plot_flag.Click_separation
            subplot(2,2,1); hold on;
            for i=1:length(final_subtrains)
                ind=final_subtrains{i};              
                dotH=plot(Clicks_within_buffer.ToAs(ind),Clicks_within_buffer.Amps(ind),'*','LineWidth',2); hold on; 
                   pause(0.05);  % calls DRAWNOW implicitly
                   set(dotH, 'XData', Clicks_within_buffer.ToAs(ind), 'YData', Clicks_within_buffer.Amps(ind)); hold on;
            end
                 
            subplot(2,2,2);
            for i=1:length(final_subtrains)
                ind=final_subtrains{i};              
                 dotH=plot(Clicks_within_buffer.ToAs(ind),Clicks_within_buffer.whale_bearing(ind),'*','LineWidth',2); hold on; 
                   pause(0.05);  % calls DRAWNOW implicitly
                   set(dotH, 'XData', Clicks_within_buffer.ToAs(ind), 'YData', Clicks_within_buffer.whale_bearing(ind)); hold on;
            end
            xlabel('Time [sec]'); ylabel('Bearing [\circ]'); 
            grid on; title('Click separation within buffers');
        end
                              
        for i=1:length(final_subtrains)
            ind=final_subtrains{i}; 
            Detections(t_index).ToAs(i)={Clicks_within_buffer.ToAs(ind)'};
            Detections(t_index).Amps(i)={Clicks_within_buffer.Amps(ind)'};
            Detections(t_index).Pkk(i)={Clicks_within_buffer.Pkk(ind)};
            Detections(t_index).whale_bearing(i)={Clicks_within_buffer.whale_bearing(ind)'};
            Detections(t_index).whale_elevation(i)={Clicks_within_buffer.whale_elevation(ind)'};
            Detections(t_index).ICI(i)={diff(Clicks_within_buffer.ToAs(ind))};
        end         
    end
    
    Detections(t_index).ToAs={};
    Detections(t_index).Amps={};
    Detections(t_index).Pkk={};
    Detections(t_index).whale_bearing={};
    Detections(t_index).whale_elevation={};
    Detections(t_index).ICI={};

end



