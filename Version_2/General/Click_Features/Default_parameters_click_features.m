function P=Default_parameters_click_features

%% Parameters settings:

     P.reflection_window=[5e-3 20e-3];  % defines the time window [in sec] around clicks for analyzing their surface echo
     P.roi=3e-3;                        % region of interest (roi)- defines the time window [in sec] around clicks for extracting their features
     P.M=2;                             % Number of dominant peaks of the click's autocorrelation 
     P.min_slant_delay=2.5e-3;          % minimum valid bound of slant delay
end