function [Locs,Amp,Locs_all,Amp_all]=Transient_selection(Y_filtered,Fs,P)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function receives a set of detected transients and output the most
%   intense ones that exceeds a certain SNR threshold

%   INPUT:
%   > Y_filtered             - Vector of MX1 samples of the bandpass filtered audio recording
%   > Fs                     - Scalar representing the sampling frequency.
%   > P                      - Struct containing the detector parameters

%   OUTPUT:
%   > Locs                  - Vector of 1XP.NOT with time of arrival in seconds for P.NOT most dominant transients
%   > Amp                   - Vector of 1XP.NOT containing the amplitude peaks of P.NOT most dominant transients
%   > Locs_all              - Vector of 1XN with time of arrival in seconds for all detected clicks
%   > Amp_all               - Vector of 1XN containing the amplitude peaks of all detected clicks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize output variables
    Locs=[];
    Amp=[];
    Locs_all=[];
    Amp_all=[];
%% Detect transients
    Y_filtered=Y_filtered';
    [~,locs] =findpeaks(abs(Y_filtered),Fs,'MinPeakDistance',P.dist_min,'MinPeakHeight',P.snr_lim);
    locs(locs<P.edge_width_locs | locs>(P.T_sec-P.edge_width_locs))=[]; 
%% Remove trasients bellow the SNR threshold   
    if ~isempty(locs)
        SNR=zeros(1,length(locs));
        for i=1:length(locs)
            click=Y_filtered(int32((locs(i)-P.pulse_len)*Fs):int32((locs(i)+P.pulse_len)*Fs));
            noise1=[Y_filtered(int32((locs(i)-2*P.pulse_len)*Fs):int32((locs(i)-P.pulse_len)*Fs)) ; Y_filtered(int32((locs(i)+P.pulse_len)*Fs):int32((locs(i)+2*P.pulse_len)*Fs))];
            noise2=Y_filtered(int32((locs(i)-3*P.pulse_len)*Fs):int32((locs(i)-P.pulse_len)*Fs));
            noise3=Y_filtered(int32((locs(i)+P.pulse_len)*Fs):int32((locs(i)+3*P.pulse_len)*Fs));
            [~,min_noise]=min([median(abs(noise1)) median(abs(noise2)) median(abs(noise3))]);
            Noise_ops={noise1,noise2,noise3};
            noise=Noise_ops{min_noise};
            [minlen,idx_min]=min([length(click) length(noise)]);
            if idx_min==1
                noise=noise(1:minlen);
            elseif idx_min==2
                click=click(1:minlen);
            end                
            SNR(i)=20*log(max(abs(click))/median(abs(noise)));                     
        end
        locs(SNR<P.SNR_thresh)=[];
        if ~isempty(locs)
           pks=Peaks_extract(Y_filtered,locs,Fs);
        else
            pks=[];
        end
        Locs=locs';
        Amp=pks;
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

end