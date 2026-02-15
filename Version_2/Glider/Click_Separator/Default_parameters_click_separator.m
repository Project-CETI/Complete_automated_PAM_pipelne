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
     P.angle_variance=5;              % maximum allowed angle variance [in degrees] within a click train (within a buffer) 
     P.max_AoA_change=20;             % maximum allowed angle variance [in degrees] between click traind (between buffers) 
     P.min_numer_of_clicks_per_whale=15; % Set minimum accepted numer of clicks per whale
     
     %% import trained models
     load All_objs.mat; 
     load Buffer_Params; 
     load F_weights;

     %% Separator parameters - click level
     P.F_weights=[0.6 0.2 0.2];        % - Vector of 1X3 with the weights given to the attributes of classes 1-3 based on their relative information gain.       
     P.All_objs=All_objs;              % - struct of 1X5 containing the GMM parameters of the clicks' similarity attributes
     P.sigma = 4;                      % - std of AoA similarity distribution of consecutive clicks (in degrees) 
     P.mu = 0;                         % - mean of AoA similarity distribution of consecutive clicks (in degrees)

     %% Separator parameters - buffer level
     P.Buffer_Params=Buffer_Params;    % - struct containing the GMM parameters of the clicks' similarity attributes in the buffer level
     P.F_weights_buffer=[0.2 0.2 0.6]; % - Vector of 1X3 with the weights given to the attributes of classes 1-3 based on their relative information gain.       
     P.sigma_buffer = 5;               % - std of AoA similarity distribution of click sequences within consecutive buffers (in degrees) 
     P.mu_buffer = 0;                  % - mean of AoA similarity distribution of click sequences within consecutive buffers (in degrees)
     P.N_val=0.0199;                   % - Normalizition factor of angle distribution 
     P.max_AoA_change_buffers=60;      % - maximum allowed angle variance between click trains [in degrees] between click traind (between buffers) 

end