
function Run_accross_folder(Program_folder,Audio_folder)

    %% Visualization
      % Plot flags
     Plot_flag.Click_presence_detection=0;
     Plot_flag.Click_detection=0;
     Plot_flag.Click_separation=0;
     Plot_flag.Coda_detection=0;

    %% Automatic determination of recording type
    if contains(Audio_folder, 'GLIDER')
        Audio_type='Glider';
    elseif contains(Audio_folder, '\wt-')
        Audio_type='Tag';
    else
        Audio_type='General';
    end
        
    %% Extract Glider's metadata 
    switch Audio_type
        case 'Glider' 
             cd(Audio_folder)
             cd ..\..\NAV\logs\    
             AllData=[];
             Meta_files=dir('*gli.sub*.gz');
             for i=1:length(Meta_files)
                extractedFiles = gunzip(Meta_files(i).name);
            
                % 2. Import the extracted file
                Data = readtable(extractedFiles{1}, 'Delimiter', ';', 'FileType', 'text');
            
                AllData=[AllData ; Data];
             end
             cd(Main_folder)
             cd ..\Complete\Glider\Click_Features\
             save('Glider_IMU.mat', 'AllData');
    end
    
    %% Determine audio format
    cd(Audio_folder)
    Files=dir('*wav');
    file_prefix=1;
    if isempty(Files)
        Files=dir('*WAV');
        file_prefix=1;
    end
    if isempty(Files)
       Files=dir('*flac');
       file_prefix=0;
    end
    
    %% Run processing over the entire folder
    for i=1:length(Files)
        i
        Audio_name=Files(i).name;
        cd(Audio_folder)
        [Raw_audio,Fs] = audioread(Audio_name);
        File.Raw_audio=Raw_audio;
        File.path=Files(i).folder;
        File.name=Files(i).name;
        File.Fs=Fs;
        cd(Program_folder)
        [Separated_codas,Separated_Clicks]=Main(File,Plot_flag);

        %% Save outputs
        if file_prefix
           Coda_save=[File.name(1:end-4) '_Codas.mat'];
           Click_save=[File.name(1:end-4) '_Clicks.mat'];
        else
           Coda_save=[File.name(1:end-5) '_Codas.mat'];
           Click_save=[File.name(1:end-5) '_Clicks.mat'];
        end
        if ~isempty(Separated_Clicks.ToAs)
           save('Click_save.mat', 'Separated_Clicks');
        end
        if ~isempty(Separated_codas{1})
           save('Coda_save.mat', 'Separated_codas');
        end
    end


end

