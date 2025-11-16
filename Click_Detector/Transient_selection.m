function [Locs,Amp,Locs_all,Amp_all]=Transient_selection(Y_filtered,ey_norm,locs,Fs,P)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function receives a set of detected transients and output the most
%   intense ones that exceeds a certain SNR threshold

%   INPUT:
%   > Y_filtered             - Vector of MX1 samples of the bandpass filtered audio recording
%   > ey_norm                - Vector of MX1 samples of the enhanced signal (after Teager-Kaizer operation)
%   > Fs                     - Scalar representing the sampling frequency.
%   > P.SNR_thresh           - Scalar representing the max SNR allowed
%   > P.NOT                  - Scalar representing a max number of transients allowed in a buffer
%   > P.SNR_window           - Scalar representing the window size (in seconds) for SNR estimation of each transient 
%   > P.crop_window          - Scalar representing the window size (in seconds) for analyzing the noise levels around candidate transients
%   > locs                   - Vector of 1XL with time of arrival in seconds for L identified transient candidates

%   OUTPUT:
%   > Locs                  - Vector of 1XP.NOT with time of arrival in seconds for P.NOT most dominant transients
%   > Amp                   - Vector of 1XP.NOT containing the amplitude peaks of P.NOT most dominant transients
%   > Locs_all              - Vector of 1XN with time of arrival in seconds for all detected clicks
%   > Amp_all               - Vector of 1XN containing the amplitude peaks of all detected clicks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parameters settings
        locs_samples=locs*Fs;
        SNR_window_samples=Fs*P.SNR_window;
        crop=Fs*P.crop_window; 

%% Discard transients bellow a pre-defined SNR

        Locs=zeros(1,P.NOT); 
        Amp=zeros(1,P.NOT);
        c=0;
        for i=1:length(locs)
            if locs_samples(i)>SNR_window_samples && (locs_samples(i)+SNR_window_samples)<length(ey_norm)
                tmp=Y_filtered(int32(locs_samples(i)-SNR_window_samples):int32(locs_samples(i))+SNR_window_samples);
                tmp_crop=Y_filtered(int32(locs_samples(i)-crop):int32(locs_samples(i)+crop));                            
                SNR=20*log(max(abs(tmp_crop))/median(abs(tmp)));
                if SNR>P.SNR_thresh 
                    c=c+1;
                    Locs(c)=locs(i);
                    Amp(c)=max(tmp_crop);
                end
            end
        end

         Locs(Locs==0)=[];
         Amp(Amp==0)=[];

         Locs_all=Locs;
         Amp_all=Amp;

%% Pick most the NOT most intense transients

       if length(Amp)>P.NOT
           [Amp,I] = maxk(Amp,P.NOT);
           Locs=Locs(I);
       end
       
%% Sort detections by time of arrival
       
       [Locs,LI]=sort(Locs);
       Amp=Amp(LI);

end