function Main(File_directory,File_name)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define directories path
     Main_folder=pwd; 
     Audio_folder=File_directory; %[Main_folder '/Data'];
     Program_folder.Click_Detector=[Main_folder '/Click_Detector'];
     Program_folder.Click_Separator=[Main_folder '/Click_Separator'];
     Program_folder.Coda_Detector=[Main_folder '/Coda_Detector'];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %% Parameter settings
    
     % User defined parameters:
     Buffer_size=30;             % Set the length of the analyzed window (in [sec])
     channel_select=1;           % Select channel for analysis
     Buffer_index=0;             % Defines the buffer number within the audio
     D_Threshold=1.42;           % set the click presence detection threshold
     c=1520;                     % Measured sound speed (in [m/sec])
     Receiver_Depth=15;          % Hydrophone depth (in [m])
     [~, lastFolder] = fileparts(File_directory);
     Tag_flag = startsWith(lastFolder, 'wt');      % set 1 for tag recording | set 0 -otherwise

     if ~Tag_flag
          SNR_thresh=52;              % Min SNR threshold [in dB] for remote recordings
     else
          SNR_thresh=100;              % Min SNR threshold [in dB] for DTag recordings
     end
     U_T=0.1;                    % Coda Detection threshold
     constarint_flag=0;          % Apply contraints: set 1 for Yes | set 0 for No
     Coda_count_threshold=3;     % Coda presence threshold - declare the presence of codas in a buffer if the number of detected codas exceeds this threshold 
    
    
     % Default parameters:
     cd(Program_folder.Click_Detector);
     Presence_detector_settings=Default_parameters_presence_detector(SNR_thresh,D_Threshold);
     cd(Program_folder.Click_Separator);
     Click_Separator_settings=Default_parameters_click_separator(Receiver_Depth,c,Tag_flag);
     cd(Program_folder.Coda_Detector)
     Coda_detector_settings=load_defalt_parameters(U_T,constarint_flag,SNR_thresh,Coda_count_threshold);  % load fixed parameters
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Visualization
      % Plot flags
         Plot_flag.Click_presence_detection=0;
         Plot_flag.Click_detection=1;
         Plot_flag.Click_separation=1;
         Plot_flag.Coda_detection=1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %% Select audio file
    % Test_files={'CETI22-027a.wav','CETI23-020.WAV','channelABCD_2023-08-26_03-06-37.wav','sw140a_Coda_16.flac'};
    Audio_name=File_name; %Test_files{1};
    
    
    while(1) 
        Buffer_index=Buffer_index+1
        cd(Program_folder.Click_Detector);
    
        %% Block 1: obtain buffer
        [Raw_audio_single_channel,Fs,Edge_flag]=read_audio(Audio_folder,Program_folder.Click_Detector,Audio_name,channel_select,Buffer_size,Buffer_index);
    
        if Edge_flag
            break;
        end
    
        %% Block 2: Click detection    
         [Click_detections,Filtered_audio_single_channel,Echolocation_clicks_Presence_flag]=Click_Detector(Raw_audio_single_channel,Presence_detector_settings,Fs,Buffer_size,Plot_flag);
    
        %% Block 3: Click separation
        clear Separated_Clicks;
        Separated_Clicks.ToAs=[];
        Separated_Clicks.Amps=[];
        if Echolocation_clicks_Presence_flag
            cd(Program_folder.Click_Separator);
            Separated_Clicks=Click_Separator(Filtered_audio_single_channel,Click_detections,Click_Separator_settings,Fs,Plot_flag);
        end
    
        %% Block 4: Coda detection
        cd(Program_folder.Coda_Detector)
        Separated_codas=Coda_Detector(Filtered_audio_single_channel,Fs,Coda_detector_settings,Click_detections,Separated_Clicks,Plot_flag);
    end

end