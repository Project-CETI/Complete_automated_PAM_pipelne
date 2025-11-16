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
        buffer=Sig(t1*Fs+1:t2*Fs);
        % t_buffer=(0:1/Fs: (1/Fs)*(length(buffer)-1))';
        
        locs=Click_detections.ToAs(Click_detections.ToAs>t1 & Click_detections.ToAs<t2);
        pks=Click_detections.Amps(Click_detections.ToAs>t1 & Click_detections.ToAs<t2);        
       
        locs_buffer=locs-t1;

        El_inds=1.1*P.roi;
        pks(locs_buffer<El_inds | locs_buffer>(P.Buffer_length-El_inds))=[];
        locs_buffer(locs_buffer<El_inds | locs_buffer>(P.Buffer_length-El_inds))=[];
   
        
        if length(locs_buffer)>P.transients_threshold 
            [ref_ToAs,locs_buffer,pks]=remove_multipass(Fs,buffer,locs_buffer,pks,t1,P.roi);
        else
            [ref_ToAs,~]=determine_reflection_ToAs(buffer,locs_buffer,0,P.roi,Fs,0);
        end
         
        if size(locs_buffer,1)>1
            locs_buffer=locs_buffer';
        end
        
        if length(locs)>P.transients_threshold
            Detected_subtrains=subtrain_detect(ref_ToAs,P.F_weights,locs_buffer,buffer,Fs,P.All_objs,P.mode); 
            Detected_subtrains=Merge_chains(Detected_subtrains,locs_buffer);
        else
            Detected_subtrains={};
        end

        if Plot_flag.Click_separation
            subplot(2,2,1); hold on;
            for i=1:length(Detected_subtrains)
                ind=Detected_subtrains{i};              
                dotH=plot(t1+locs_buffer(ind),pks(ind),'*','LineWidth',2); hold on; 
                   pause(0.05);  % calls DRAWNOW implicitly
                   set(dotH, 'XData', t1+locs_buffer(ind), 'YData', pks(ind)); hold on;
            end
                 
            subplot(2,2,2);
            for i=1:length(Detected_subtrains)
                ind=Detected_subtrains{i};              
                dotH=plot(t1+locs_buffer(ind),ref_ToAs(ind),'*','LineWidth',2); hold on; 
                   pause(0.05);  % calls DRAWNOW implicitly
                   set(dotH, 'XData', t1+locs_buffer(ind), 'YData', ref_ToAs(ind)); hold on;
            end
            xlabel('Time [sec]'); ylabel('Slant delay [ms]'); 
            grid on; title('Click separation within buffers');
        end
                              
        for i=1:length(Detected_subtrains)
            ind=Detected_subtrains{i}; 
            Detections(t_index).ToAs(i)={t1+locs_buffer(ind)'};
            Detections(t_index).Pkk(i)={Power_estimates(Sig,t1+locs_buffer(ind),Fs)};
            Detections(t_index).ref(i)={ref_ToAs(ind)};
            Detections(t_index).ICI(i)={diff(sort(t1+locs_buffer(ind)))};
            Detections(t_index).wav_avg(i)={Waveform_average(t1+locs_buffer(ind),Fs,Sig,0)};
        end
        if ~isempty(Detected_subtrains)
            Detections(t_index).Confidence=Mean_JF(Detections(t_index),buffer,Fs,P.Buffer_length,t_index);
        end
         
    end
    
    Detections(t_index).Confidence=[];
    Detections(t_index).ToAs={};
    Detections(t_index).Pkk={};
    Detections(t_index).ref={};
    Detections(t_index).ICI={};
    Detections(t_index).wav_avg={};

end



