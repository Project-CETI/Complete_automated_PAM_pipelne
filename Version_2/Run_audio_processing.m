clear all; clc;

Program_folder='H:\Testing_Files\Automated_Processing'; 

%% Pick recording type for testing
%Choices: remote_coda/remote_click_folder/glider/tag_click/tag_coda/Towed_array
Testing_type='tag_coda';

switch Testing_type
    case 'remote_coda'
        Audio_folder='H:\Testing_Files\Remote\Codas';
    case 'remote_click'
        Audio_folder='H:\Testing_Files\Remote\Clicks';
    case 'glider'
        Audio_folder='H:\Testing_Files\Glider\PLD1\acoustic';
    case 'tag_click'
        Audio_folder='H:\Testing_Files\Tags\Clicks\wt-02040028';
    case 'tag_coda'
        Audio_folder='H:\Testing_Files\Tags\Codas\wt-02040028';
    case 'Towed_array'
        Audio_folder='H:\raw\2024-09-17\CETI-TOWED_ARRAY';
end

%% Run script over all audio files in the selected folder
Run_accross_folder(Program_folder,Audio_folder)
