function [Click_Detections,Filtered_audio_single_channel,Echolocation_clicks_Presence_flag]=Click_Detector(Raw_audio_single_channel,P,Fs,Buffer_size,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           November 2025
%   DESCRIPTION:

%   This function gets a buffer from a raw audio file 
%   and returns the signal after spectral filtering along with 
%   the arrival times of click detections. 

%   INPUT:
%   > Raw_audio_single_channel - Vector of MX1 comprising 1 channel of M samples of a segment from a the audio file
%   > Buffer_size              - Scalar representing the length of the analyzed segment (in [sec])
%   > Fs                       - Scalar representing the sampling frequency.
%   > P                        - Struct containing the detector parameters
%   > Plot_flag                - Flag for visualizing results

%   OUTPUT:
%   > Click_Detections                   - Struct containing the arrival times and amplitudes of the detected clicks 
%   > Filtered_audio_single_channel      - Vector of MX1 comprising the band-pass filtered 1 channel of M samples of the segmented audio
%   > Echolocation_clicks_Presence_flag  - scalar representing wether sperm whale echolocation clicks are presented (1) or not (2) in the buffer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Click_ToAs=[];
    Click_Amps=[];
    Filtered_audio_single_channel=[];
    Echolocation_clicks_Presence_flag=1;
    Detection_counter=0;

    for window_idx=1:floor(Buffer_size/P.T_sec)
         Y_window=Raw_audio_single_channel((window_idx-1)*P.T_sec*Fs+1:window_idx*P.T_sec*Fs);
         Y_filtered=bandpass(Y_window,[P.F_low, P.F_high],Fs); % Apply bandpass filter within the frequency range specified by the parameters F_low and F_high
    
         [ey,~]=energyop(Y_filtered,0);          % Apply TKEO (ey is the output signal with enhanced SNR)
         ey_norm=ey/max(ey);                     % Normalize the enhaced signal ey          
         ty=0:1/Fs:(1/Fs)*(length(Y_filtered)-1); 
         [~,locs] =findpeaks(ey_norm,Fs,'MinPeakDistance',P.Click_duration); % Detect transients
         [Locs,Amp,Locs_all,Amp_all]=Transient_selection(Y_filtered,ey_norm,locs,Fs,P); % Eliminate transients bellow a pre-defined threshold
        
         if length(Locs)>P.transients_threshold
           El_inds=P.MPS_max+2e-3;
           Locs(Locs<El_inds | Locs>(P.T_sec-El_inds))=[];
           Amp(Locs<El_inds | Locs>(P.T_sec-El_inds))=[];
           IPI_vec=MPS_extract(Y_filtered,Fs,Locs,P);
           [C_inds,S_g_min]=Cluster_MPS(IPI_vec,Locs,Amp,P);
           if S_g_min<P.D_Threshold
              Detection_counter=Detection_counter+1;
           end

           if Plot_flag.Click_presence_detection
               figure; plot(ty,Y_filtered); hold on; 
               plot(Locs,Amp,'*','LineWidth',2); 
               plot(Locs(C_inds),Amp(C_inds),'o','LineWidth',2);
               title(['U_T= ' num2str(round(S_g_min,2))]);
           end
    
           Click_ToAs=[Click_ToAs Locs_all+P.T_sec*(window_idx-1)];
           Click_Amps=[Click_Amps Amp_all];
         end  
           Filtered_audio_single_channel=[Filtered_audio_single_channel Y_filtered];
    end

    if ~Detection_counter
        Echolocation_clicks_Presence_flag=0;
    end
    
    if Plot_flag.Click_detection
        t_filtered=0:1/Fs:(1/Fs)*(length(Filtered_audio_single_channel)-1);
        figure; plot(t_filtered,Filtered_audio_single_channel); hold on; 
        plot(Click_ToAs,Click_Amps,'*','LineWidth',2); 
    end

    Click_Detections.ToAs=Click_ToAs;
    Click_Detections.Amps=Click_Amps;

end

