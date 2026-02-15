function Follow_bearing=Main_glider(Audio_name)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define directories path
     Main_folder=pwd; 
     Program_folder.Click_Detector=[Main_folder '/Click_Detector'];
     Program_folder.Click_Features=[Main_folder '/Click_Features'];
     Program_folder.Click_Separator=[Main_folder '/Click_Separator'];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %% Parameter settings
     cd(Program_folder.Click_Detector);
     Presence_detector_settings=Default_parameters_presence_detector;
     cd(Program_folder.Click_Features);
     Click_features_settings=Default_parameters_click_features;
     cd(Program_folder.Click_Separator);
     Click_Separator_settings=Default_parameters_click_separator;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Visualization
      % Plot flags
     Plot_flag.Click_presence_detection=0;
     Plot_flag.Click_detection=0;
     Plot_flag.Click_separation=1;
     Plot_flag.Chosen_whale=1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %% Select audio file
    cd(Main_folder)
    [Raw_audio,Fs] = audioread(Audio_name);

    %% Block 1: Channel selection
    S_t=Raw_audio(:,Click_features_settings.channel_select)';

    %% Block 2: High-pass filtering (single channel)
    S_t_filtered=filtfilt(Click_features_settings.sos, Click_features_settings.g, S_t);

    %% Block 3: Click detection   
    cd(Program_folder.Click_Detector);
    [Click_detections,Echolocation_clicks_Presence_flag]=Click_Detector(S_t_filtered,Presence_detector_settings,Fs,Plot_flag);

    if Echolocation_clicks_Presence_flag        
        %% Block 4: High-pass filtering (reminder channels)
        S_t_HPF_reminder_channels=filtfilt(Click_features_settings.sos, Click_features_settings.g, Raw_audio(:,Click_features_settings.Reminder_channels));
        S_t_HPF(:,Click_features_settings.Reminder_channels)=S_t_HPF_reminder_channels;
        S_t_HPF(:,Click_features_settings.channel_select)=S_t_filtered;

        %% Block 5: AoA estimation
        cd(Program_folder.Click_Features)
        Click_detections=Extract_click_AoAs(Audio_name,S_t_HPF,Click_detections,Click_features_settings,Fs);
    
        %% Block 5: Feature extraction
        Click_detections=extract_click_features(Click_detections);
    
        %% Block 6: Click separation    
        cd(Program_folder.Click_Separator);
        [Separated_Clicks,Separated_clicks_flag]=Click_Separator(S_t_HPF(:,1),Click_detections,Click_Separator_settings,Fs,Plot_flag);
            
        %% Block 7: Select whale
        if Separated_clicks_flag
            Follow_bearing=Select_whale_to_track(S_t_HPF(:,1),Fs,Separated_Clicks,Plot_flag);
        else
            Follow_bearing=[];
        end
    else
        Follow_bearing=[];
    end

    cd(Main_folder)
end

