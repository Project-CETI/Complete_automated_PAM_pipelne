function [Y,F_ds]=read_audio(DF,PF)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           July 2025
%   DESCRIPTION:

% read_audio Returns a random 10-second segment from a random audio file  

%   INPUT:
%   > DF             - Directory of the data folder
%   > PF             - Directory of the current folder (program folder)

%   OUTPUT:
%   > Y              - Matrix of MX2 comprising 2 channels of M samples of a random 10-second segment from a random audio file
%   > F_ds           - Scalar representing the sampled frequency of the audiofile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read Audio
    cd(DF)
    files=dir('*.wav');
    n=randi([1, 21]);
    filename=files(n).name;
    [y,F_ds] = audioread(filename);            % read recording
    n = randi([1, round(size(y,1)/F_ds)-10]);
    Random_buffer=n*F_ds+1:(n+10)*F_ds;
    Y=y(Random_buffer,:);                     % Choose one channel from the WRU
    cd(PF)

end