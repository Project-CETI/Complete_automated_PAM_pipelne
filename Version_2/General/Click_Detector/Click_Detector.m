function [Click_Detections,Echolocation_clicks_Presence_flag]=Click_Detector(S_t_filtered,P,Fs,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           November 2025
%   DESCRIPTION:

%   This function gets a buffer from a raw audio file 
%   and returns the signal after spectral filtering along with 
%   the arrival times of click detections. 

%   INPUT:
%   > S_t_filtered             - Vector of MX1 comprising 1 channel of M samples of a segment from a the audio file
%   > Fs                       - Scalar representing the sampling frequency.
%   > P                        - Struct containing the detector parameters
%   > Plot_flag                - Flag for visualizing results

%   OUTPUT:
%   > Click_Detections                   - Struct containing the arrival times and amplitudes of the detected clicks 
%   > Echolocation_clicks_Presence_flag  - scalar representing wether sperm whale echolocation clicks are presented (1) or not (2) in the buffer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Click_ToAs=[];
    Click_Amps=[];
    Buffer_size=length(S_t_filtered)/Fs;
    Echolocation_clicks_Presence_flag=1;
    Detection_counter=0;

    for window_idx=1:floor(Buffer_size/P.T_sec)
         Y_window=S_t_filtered((window_idx-1)*P.T_sec*Fs+1:window_idx*P.T_sec*Fs);
         [Locs,Amp,Locs_all,Amp_all]=Transient_selection(Y_window,Fs,P);
         ty=0:1/Fs:(1/Fs)*(length(Y_window)-1); 

         if length(Locs)>P.transients_threshold
           IPI_vec=MPS_extract(Y_window,Fs,Locs,P);
           [C_inds,S_g_min]=Cluster_MPS(IPI_vec,Locs,Amp,P);
           if S_g_min<P.D_Threshold
              Detection_counter=Detection_counter+1;
           end

           if Plot_flag.Click_presence_detection
               figure; plot(ty,Y_window); hold on; 
               plot(Locs,Amp,'*','LineWidth',2); 
               plot(Locs(C_inds),Amp(C_inds),'o','LineWidth',2);
               title(['U_T= ' num2str(round(S_g_min,2))]);
           end
    
           Click_ToAs=[Click_ToAs Locs_all+P.T_sec*(window_idx-1)];
           Click_Amps=[Click_Amps Amp_all];
         end  
    end

    if length(S_t_filtered)-window_idx*P.T_sec*Fs>50
         Y_window=S_t_filtered(window_idx*P.T_sec*Fs+1:end);
         [~,~,Locs_all,Amp_all]=Transient_selection(Y_window,Fs,P);
         Click_ToAs=[Click_ToAs Locs_all+P.T_sec*window_idx];
         Click_Amps=[Click_Amps Amp_all];
    end

    if ~Detection_counter
        Echolocation_clicks_Presence_flag=0;
    end
    
    if Plot_flag.Click_detection
        t_filtered=0:1/Fs:(1/Fs)*(length(S_t_filtered)-1);
        figure; plot(t_filtered,S_t_filtered); hold on; 
        plot(Click_ToAs,Click_Amps,'*','LineWidth',2); 
    end

    Click_Detections.ToAs=Click_ToAs;
    Click_Detections.Amps=Click_Amps;

end

