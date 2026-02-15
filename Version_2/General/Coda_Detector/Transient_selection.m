function [Locs,Pks]=Transient_selection(Y_filtered,ey_norm,locs,pks,F_ds,SNR_thresh,SNR_window,crop_window,NOT)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function receives a set of detected transients and output the most
%   intense ones that exceeds a certain SNR threshold

%   INPUT:
%   > Y_filtered             - Vector of MX1 samples of the bandpass filtered audio recording
%   > ey_norm                - Vector of MX1 samples of the enhanced signal (after Teager-Kaizer operation)
%   > F_ds                   - Scalar representing the sampling frequency.
%   > SNR_thresh             - Scalar representing the max SNR allowed
%   > NOT                    - Scalar representing a max number of transients allowed in a buffer
%   > SNR_window             - Scalar representing the window size (in seconds) for SNR estimation of each transient 
%   > crop_window            - Scalar representing the window size (in seconds) for analyzing the noise levels around candidate transients
%   > locs                   - Vector of 1XL with time of arrival in seconds for L identified transient candidates
%   > pks                    - Vector of 1XL containing the amplitude peaks of L identified transient candidates

%   OUTPUT:
%   > Locs                  - Vector of 1XN with time of arrival in seconds for N most dominant transients
%   > Pks                   - Vector of 1XN containing the amplitude peaks of N most dominant transients

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parameters settings
        locs_samples=locs*F_ds;
        SNR_window_samples=F_ds*SNR_window;
        crop=F_ds*crop_window; 

%% Discard transients bellow a pre-defined SNR

        Locs=zeros(1,NOT); 
        Pks=zeros(1,NOT); 
        c=0;
        for i=1:length(locs)
            if locs_samples(i)>SNR_window_samples && (locs_samples(i)+SNR_window_samples)<length(ey_norm)
                tmp=Y_filtered(int32(locs_samples(i)-SNR_window_samples):int32(locs_samples(i))+SNR_window_samples);
                tmp_crop=Y_filtered(int32(locs_samples(i)-crop):int32(locs_samples(i)+crop));                            
                SNR=20*log(max(abs(tmp_crop))/median(abs(tmp)));
                if SNR>SNR_thresh 
                    c=c+1;
                    Locs(c)=locs(i);
                    Pks(c)=pks(i);
                end
            end
        end

         Locs(Locs==0)=[];
         Pks(Pks==0)=[];

%% Pick most the NOT (30 by default) most intense transients

       if length(Pks)>NOT
           [Pks2,I] = maxk(Pks,NOT);
           Locs2=Locs(I);
           Pks=Pks2;
           Locs=Locs2;
       end
       
%% Sort detections by time of arrival
       
       [Locs,LI]=sort(Locs);
       Pks=Pks(LI);

end