function P=Default_parameters_click_separator(Receiver_Depth,c,Tag_flag)

%% Parameters settings:

     P.roi=2*Receiver_Depth/c;     % region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
     P.Buffer_length=3;            % Analysis buffer length [sec] 
     P.lone_p=20;                  % Lone penalty (used for click train formation)      
     P.ITI_min=3;                  % minimum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
     P.ITI_max=30;                 % maximum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
     P.transients_threshold=2;     % minimum number of transient detections for considering further processing
     P.mode=0;
     P.Tag_flag=Tag_flag;
     P.n_clicks=16;
     P.rank_threshold=10;
     %% import trained models
     load All_objs.mat; load Buffer_Params; load F_weights;
     P.Buffer_Params=Buffer_Params;    %- struct containing the GMM parameters of the clicks' similarity attributes in the buffer level
     P.F_weights=F_weights;            %- Vector of 1X4 with the weights given to the attributes of classes 1-4 based on their relative information gain.       
     P.All_objs=All_objs;              % - struct of 1X5 containing the GMM parameters of the clicks' similarity attributes
   end