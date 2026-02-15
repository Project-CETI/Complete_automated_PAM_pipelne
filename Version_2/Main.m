function [Separated_codas,Separated_Clicks]=Main(File,Plot_flag)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define directories path
     Main_folder=pwd; 
     [~, lastFolder] = fileparts(File.path);
     Tag_flag = startsWith(lastFolder, 'wt');      % set 1 for tag recording | set 0 -otherwise
     Glider_flag = startsWith(File.name, 'sea');      % set 1 for glider recording | set 0 -otherwise

     if Glider_flag
         Program_folder.Click_Detector=[Main_folder '\Glider\Click_Detector'];
         Program_folder.Click_Features=[Main_folder '\Glider\Click_Features'];
         Program_folder.Click_Separator=[Main_folder '\Glider\Click_Separator'];
         Program_folder.Coda_Detector=[Main_folder '\Glider\Coda_Detector'];
     else
         Program_folder.Click_Detector=[Main_folder '\General\Click_Detector'];
         Program_folder.Click_Features=[Main_folder '\General\Click_Features'];
         Program_folder.Click_Separator=[Main_folder '\General\Click_Separator'];
         Program_folder.Coda_Detector=[Main_folder '\General\Coda_Detector'];
     end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %% Parameter settings
     channel_select=1;
     cd(Program_folder.Click_Detector);
     Presence_detector_settings=Default_parameters_presence_detector(Tag_flag);
     cd(Program_folder.Click_Features);
     Click_features_settings=Default_parameters_click_features;
     cd(Program_folder.Click_Separator);
     Click_Separator_settings=Default_parameters_click_separator;
     cd(Program_folder.Coda_Detector)
     Coda_detector_settings=load_defalt_parameters;  % load fixed parameters
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

    %% Block 1: Channel selection
    S_t=File.Raw_audio(:,channel_select)';

    %% Block 2: Spectral filtering
    if Glider_flag
        S_t_filtered=filtfilt(Click_features_settings.sos, Click_features_settings.g, S_t);
    else
        S_t_filtered=filtfilt(Presence_detector_settings.sos, Presence_detector_settings.g, S_t);
    end

    %% Block 3: Click detection   
    cd(Program_folder.Click_Detector);
    [Click_detections,Echolocation_clicks_Presence_flag]=Click_Detector(S_t_filtered,Presence_detector_settings,File.Fs,Plot_flag);

    if Glider_flag
        %% High-pass filtering (reminder channels)
        S_t_HPF_reminder_channels=filtfilt(Click_features_settings.sos, Click_features_settings.g, File.Raw_audio(:,Click_features_settings.Reminder_channels));
        S_t_HPF(:,Click_features_settings.Reminder_channels)=S_t_HPF_reminder_channels;
        S_t_HPF(:,Click_features_settings.channel_select)=S_t_filtered;
    end

    cd(Program_folder.Click_Features)
    if Glider_flag
         %% Block 4: AoA estimation
        Click_detections=Extract_click_AoAs(File.name,S_t_HPF,Click_detections,Click_features_settings,File.Fs);
    else
        %% Block 4: Slant delay estimation
        Click_detections=Extract_slant_delays(S_t_filtered,Click_detections,Click_features_settings,File.Fs);
    end

    %% Block 5: Feature extraction
    Click_detections=extract_click_features(Click_detections);

    %% Block 6: Click separation
    if Echolocation_clicks_Presence_flag
        cd(Program_folder.Click_Separator);
        Separated_Clicks=Click_Separator(S_t_filtered,Click_detections,Click_Separator_settings,File.Fs,Plot_flag);
    else
        Separated_Clicks.ToAs=[];
        Separated_Clicks.Amps=[];
    end

    %% Block 7: Coda detection
        cd(Program_folder.Coda_Detector)
        Separated_codas=Coda_Detector(S_t_filtered,File.Fs,Coda_detector_settings,Click_detections,Separated_Clicks,Plot_flag);
        cd(Main_folder)
end




