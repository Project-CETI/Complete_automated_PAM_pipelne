function P=Default_parameters_presence_detector(Tag_flag)

%% Parameters settings:
    P.PPR=0.4;                  % Pulse peak ratio (PPR) between consecutive pulses in a click
    P.pulse_len=1e-3;           % Length in [sec] of the click's main pulse
    P.dist_min=6e-3;            % minimum distance between consecutive clicks
    P.snr_lim=1.5e-3;           % minimum abs amplitude threshold 
    P.Click_duration=2*25e-3;   % set maximum duration of a click (including multi-pulses)
    P.T_sec=10;                 % Analysis window in [sec]
    P.MPS_max=5e-3;             % Set the maximum plausible IPI of sperm whale clicks
    P.IPI_min=1.8e-3;           % Set the minimum plausible IPI of sperm whale clicks
    P.SNR_window=0.1;           % window size [in sec] for SNR estimation of transient signals 
    P.crop_window=3e-3;         % window size [in sec] for analyzing the noise levels around candidate transients
    P.transients_threshold=3;   % minimum number of transient detections for considering further processing
    P.NOT=25;                   % maximum allowed number of transients in a buffer
    P.edge_width=0.9e-3;        % set window [in sec] to avoid numerical issues near edges of analysis windows
    P.edge_width_locs=5.5e-3;   % set window [in sec] to to remove click detections too close to the analyzed buffer
    P.ICI_Min=0.4;              % Minimum allowed ICI of echolocation clicks
    P.ICI_Max=2;                % Maximum allowed ICI of echolocation clicks
    P.Consi_max=0.22;           % Maximum allowed of median of Consistency of coda clicks
    P.rank_click_train_max=6;   % Set a max size for click train candidate clusters (Note that ranks higher than 7 may cause complexity issues)
    P.rank_click_train_min=3;   % Set a min size for click train candidate clusters 
    P.alpha1=20;                % Normalizing factor to weight the penalty over the cluster’s rank
    P.alpha2=1;                 % Normalizing factor to weight the penalty over the cluster’s amplitude stability
    P.SNR_thresh=52;            % Min SNR threshold [in dB]
    P.D_Threshold=1.42;         % set the click presence detection threshold

end