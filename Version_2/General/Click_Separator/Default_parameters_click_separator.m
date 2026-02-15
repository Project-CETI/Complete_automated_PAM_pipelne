function P=Default_parameters_click_separator

%% Parameters settings:
     P.min_subtrain_rank=3;          % Minimum number of clicks in a formed subtrain
     P.roi=0.02;                     % region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
     P.Buffer_length=3;              % Analysis buffer length [sec] 
     P.lone_p=20;                    % Lone penalty (used for click train formation)      
     P.lone_p_click_separaton=-0.1;  % Lone penalty (used for click separation within buffers)    
     P.ITI_min=3;                    % minimum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
     P.ITI_max=30;                   % maximum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
     P.ICI_min=0.4;                  % minimum allowed time gap between clicks (Inter-click interval (ICI))  [sec]
     P.ICI_max=2.5;                  % maximum allowed time gap between clicks (Inter-click interval (ICI))  [sec]
     P.max_slant_delay_variance=1.5; % Max allowed variance of slant delay within a click sequence
     P.max_ICI_consitency=0.1;       % Max allowed time spacing consistency of clicks within a sequence
     P.transients_threshold=2;       % minimum number of transient detections for considering further processing
     P.n_clicks=16;
     P.rank_threshold=10;
     %% import trained models
     load All_objs.mat; 
     load Buffer_Params; 
     % load F_weights;
     P.Buffer_Params=Buffer_Params;    %- struct containing the GMM parameters of the clicks' similarity attributes in the buffer level
     P.F_weights=[0.5 0.25 0.25];      %- Vector of 1X4 with the weights given to the attributes of classes 1-4 based on their relative information gain.       
     P.All_objs=All_objs;              % - struct of 1X5 containing the GMM parameters of the clicks' similarity attributes
   end