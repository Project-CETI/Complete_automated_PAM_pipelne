function [Separated_whales,Separated_clicks_flag]=Click_Separator(Sig,Click_detections,P,Fs,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           November 2025
%   DESCRIPTION:

%   This function gets a signal with echolocation click detections 
%   and separates and attributes the clicks to different source whales. 

%   INPUT:
%   > Sig                      - Vector of MX1 comprising the band-pass filtered 1 channel of M samples of a buffered audio
%   > Click_Detections         - Struct containing the arrival times and amplitudes of the detected clicks 
%   > Fs                       - Scalar representing the sampling frequency.
%   > P                        - Struct containing the detector parameters
%   > Plot_flag                - Flag for visualizing results


%   OUTPUT:
%   > Separated_whales         - Struct containing the arrival times and amplitudes of the clicks associated with each whale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%  Click separation within buffers
                    
    Detections=run_subtrain_detect(Sig,Click_detections,P,Fs,Plot_flag); 

    %%  Click train formation (sequences' association between buffers)

    [trajectories,id_clicks]=run_train(Detections,P,Plot_flag);

    %%  Association of click trains

    Separated_whales=run_trains_association_algo(trajectories,id_clicks,Sig,Fs,P,Plot_flag);
      
    if isempty(Separated_whales(1).ToAs)
         Separated_clicks_flag=0;
    else
        Separated_clicks_flag=1;
    end
end

