function [Raw_audio_single_channel,Fs,Edge_flag]=read_audio(DF,PF,Audio_name,channel_select,buffer_size,buffer_index)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           July 2025
%   DESCRIPTION:

% read_audio Returns a specified segment from a given audio file  

%   INPUT:
%   > DF               - Directory of the data folder
%   > PF               - Directory of the program folder
%   > Audio_name       - Full_name.format of the audio file
%   > channel_select   - User defined channel selection from the audio file
%   > buffer_size      - User defined window size for analysis 
%   > buffer_index     - Start index for buffer selection 

%   OUTPUT:
%   > Raw_audio_single_channel      - Vector of MX1 comprising 1 channel of M samples of a 30-second segment from a the audio file
%   > Fs                            - Scalar representing the sampled frequency of the audiofile
%   > Edge_flag                     - Scalar that is set to 1 if the buffer index exceeds the audio length, and is set to 0 otherwise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Edge_flag=0;  
    cd(DF)
    Audio_info=audioinfo(Audio_name);
    Fs=Audio_info.SampleRate;

    if buffer_index*buffer_size<Audio_info.Duration
        Raw_audio = audioread(Audio_name,[(buffer_index-1)*buffer_size*Fs+1,buffer_index*buffer_size*Fs]);            % read recording
        L=size(Raw_audio);
        if L(2)<L(1)
            Raw_audio=Raw_audio';
        end   
        Raw_audio_single_channel=Raw_audio(channel_select,:);        % Extract the selected channel   
        t=(0:1/Fs: (1/Fs)*(length(Raw_audio_single_channel)-1))';
        % figure; plot(t,Raw_audio_single_channel)
    else
        Edge_flag=1;
        Raw_audio_single_channel=[];
    end
    cd(PF)
    
    

end