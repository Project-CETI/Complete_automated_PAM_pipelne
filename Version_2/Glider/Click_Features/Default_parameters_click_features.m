function P=Default_parameters_click_features

     %% Parameters settings:
     P.Channels_idx=[2 4 1 3];          % Order of channels with respect of the predefind glider frame
     P.roi=1.5e-3;                      % region of interest (roi)- defines the time window [in sec] around clicks for extracting their features     
     d = 0.15;                          % Set the distance [in m] between sensors in the array
     P.channel_select=1;                % Choose channel for processing the click detection phase
     P.Reminder_channels=~ismember(1:4,P.channel_select);   
     P.sensor_pos = [
            0,     0,              0;
            d,     0,              0;
            d/2,   d*sqrt(3)/2,    0;
            d/2,   d*sqrt(3)/6,    d*sqrt(2/3)   % Define sensors postion in the array frame
        ];
     %% import filter parameters
     load hp_filter_sos.mat;            % load HPF (2khz) parameters (sos and g)
     P.sos=sos;
     P.g=g;
     % import Glider metadata   
     load Glider_IMU;   % load table with glider's IMU measurements
     P.AllData=AllData;       % glider's IMU measurements


end