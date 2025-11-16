function [Y,Yp]=Extract_signal(Y_filtered,locs,F_ds,W_seg,seg_percentage)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function gets a measured signal and a vector of arrival time of
%   clicks and extract the clicks' waveform (Y) and peak amplitude (Yp)

%   INPUT:
%   > Y_filtered             - Vector of MX1 samples of the bandpass filtered audio recording
%   > F_ds                   - Scalar representing the sampling frequency.
%   > W_seg                  - Scalar representing a window [in sec] set to extract the transient waveform
%   > seg_percentage         - Scalar representing a percentage of window segment used for (for accurate capturing of coda click waveform)
%   > locs                   - Vector of 1XN with time of arrival within seconds for N most dominant transients in the buffer

%   OUTPUT:
%   > Y                      - Matrix of LXN containg L waveform samples of each of the N most dominant transients within the buffer
%   > Yp                     - Vector of 1XN with mean amplitude's peak to peak level of the N most dominant transients within the buffer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % W_seg=9e-3;
    seg_ds=round(W_seg*F_ds); 
    locs_samples=locs*F_ds; 
    Max_size=round(seg_percentage*seg_ds)+seg_ds;
    Y=zeros(Max_size,length(locs));
    Yp=zeros(1,length(locs));

    for ind=1:length(locs)
        if  (locs_samples(ind)+seg_ds)<length(Y_filtered) && locs_samples(ind)-round(seg_ds)>0
           Y_bank= Y_filtered(int32(locs_samples(ind)-round(seg_percentage*seg_ds)):int32(locs_samples(ind)+seg_ds)); 
        elseif  (locs_samples(ind)+seg_ds)<length(Y_filtered)
           Y_bank= Y_filtered(1:int32(locs_samples(ind)+seg_ds));            
        else           
           Y_bank= Y_filtered(int32(locs_samples(ind)-round(seg_percentage*seg_ds)):int32(length(Y_filtered)));   % pick region of analysis
        end 

        Y(1:length(Y_bank),ind)=Y_bank/max(Y_bank);
        Yp(ind)=mean([max(Y_bank) abs(min(Y_bank))]);
        
    end

end
