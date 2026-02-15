function IPI_vec=MPS_extract(Y_filtered,Fs,Locs,P)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function gets a set of clicks and output their corresponding IPI estimations

%   INPUT:
%   > Y_filtered               - Vector of MX1 samples of the bandpass filtered audio recording
%   > Fs                       - Scalar representing the sampling frequency.
%   > Locs                     - Vector of 1XN with time of arrival [in seconds] for N most dominant transients in the buffer
%   > P                        - Struct containing the detector parameters

%   OUTPUT:
%   > IPI_vec                - Vector of 1XN with IPI estimations (in [sec]) of the N most dominant transients within the buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    W=P.MPS_max*Fs;        
    IPI_vec=zeros(1,length(Locs));

    for j=1:length(Locs)
        Y_bank=Y_filtered(int32(Locs(j)*Fs-W):int32(Locs(j)*Fs+W));
        [ey,~]=energyop(Y_bank);                % Apply TKEO (ey is the output signal with enhanced SNR)
        ey_norm=ey/max(ey);                     % Normalize the enhaced signal ey          
        time=0:1/Fs:(1/Fs)*(length(ey_norm)-1);   
        [Pk,Lo] =findpeaks(ey_norm,Fs,'MinPeakDistance',P.IPI_min);  % Apply instantaneous energy detector (find peaks)          
    
        Pk(Lo<P.edge_width)=[];
        Lo(Lo<P.edge_width)=[];
        Pk(Lo>time(end)-P.edge_width)=[];
        Lo(Lo>time(end)-P.edge_width)=[];
         
        [pk1,I1]=sort(Pk);
        Main_peak=Lo(I1(end));
        Lz=length(Pk);
        if Lz>2
            RP=(pk1(end-1)-pk1(end-2))/pk1(end-1);                                      
            if RP<P.PPR && abs(Lo(I1(end-2))-Main_peak)>abs(Lo(I1(end-1))-Main_peak) 
                Second_pulse=find(Pk==pk1(end-2));
            else
                Second_pulse=find(Pk==pk1(end-1));
            end
        else                   
           Second_pulse=find(Pk==pk1(end-1));
        end
        IPI_estimate=abs(Main_peak-Lo(Second_pulse));
        if IPI_estimate>P.IPI_min 
            MPS=IPI_estimate;
        else
            MPS=IPI_min;        %set min window size
        end
        IPI_vec(j)=MPS;
    end

    
            
end



