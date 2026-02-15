
function IPI_vec=MPS_extract(MPS_max,IPI_min,F_ds,Y_filtered,Locs,edge_width)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function gets a set of clicks and output their corresponding IPI estimations

%   INPUT:
%   > Y_filtered             - Vector of MX1 samples of the bandpass filtered audio recording
%   > F_ds                   - Scalar representing the sampling frequency.
%   > MPS_max                - Scalar representing the maximum plausible IPI [in sec] of sperm whale clicks
%   > IPI_min                - Scalar representing the minimum plausible IPI [in sec] of sperm whale clicks
%   > edge_width             - Scalar representing a window [in sec] set to avoid numerical issues near edges of analysis windows
%   > Locs                   - Vector of 1XN with time of arrival within seconds for N most dominant transients in the buffer

%   OUTPUT:
%   > IPI_vec                - Vector of 1XN with IPI estimations of the N most dominant transients within the buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    W=MPS_max*F_ds;        
    IPI_vec=zeros(1,length(Locs));

    for j=1:length(Locs)
        Y_bank=Y_filtered(int32(Locs(j)*F_ds-W):int32(Locs(j)*F_ds+W));
        [ey,~]=energyop(Y_bank);              % Apply TKEO (ey is the output signal with enhanced SNR)
        ey_norm=ey/max(ey);                     % Normalize the enhaced signal ey          
        time=0:1/F_ds:(1/F_ds)*(length(ey_norm)-1);   
        [Pk,Lo] =findpeaks(ey_norm,F_ds,'MinPeakDistance',IPI_min);  % Apply instantaneous energy detector (find peaks)          
    
        Pk(Lo<edge_width)=[];
        Lo(Lo<edge_width)=[];
        Pk(Lo>time(end)-edge_width)=[];
        Lo(Lo>time(end)-edge_width)=[];
         
        [pk1,I1]=sort(Pk);
        Main_peak=Lo(I1(end));
        Lz=length(Pk);
        if Lz>2
            RP=(pk1(end-1)-pk1(end-2))/pk1(end-1);                                      
            if RP<0.4 && abs(Lo(I1(end-2))-Main_peak)>abs(Lo(I1(end-1))-Main_peak) 
                Second_pulse=find(Pk==pk1(end-2));
            else
                Second_pulse=find(Pk==pk1(end-1));
            end
        else                   
           Second_pulse=find(Pk==pk1(end-1));
        end
        IPI_estimate=abs(Main_peak-Lo(Second_pulse));
        if IPI_estimate>IPI_min 
            MPS=IPI_estimate;
        else
            MPS=IPI_min;        %set min window size
        end
        IPI_vec(j)=1e3*MPS;
    end

    
            
end



