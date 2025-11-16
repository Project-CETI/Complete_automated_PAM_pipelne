function F=Spectral_features_extraction(s,fs,Ind_min,IPI)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           July 2025
%   DESCRIPTION:

%   This function gets a sperm whale click measurement and calculates its resonance frequency.

%   INPUT:
%   > s                  -  1XM vector representing a measured click signal
%   > fs                 -  A scalar representing the sample rate of the measured signal
%   > Ind_min            -  A scalar representing the sampled arrival time of a click's dominant pulse
%   > IPI                -  A scalar representing the click's estimated IPI

%   OUTPUT:
%   > f_resonance        - A scalar representing the resonance frequency of the input click signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    W_size=int32(fs*0.5e-3*IPI);
    x=s(Ind_min-W_size:Ind_min+W_size);

    % N = length(x);
    % X = fft(x);
    % f = (0:N-1)*(fs/N);  % frequency vector
    % 
    % % Use only the first half (positive frequencies)
    % X_mag = abs(X(1:floor(N/2)));
    % f = f(1:floor(N/2));

    [Px, f] = pwelch(x, [], [], [], fs);   % Px1: power vs f1 (Hz)

    fmax = 24e3;     

     Nf = 1e3;    % choose a reasonable resolution
     f_common = linspace(0, fmax, Nf).';
     Pxc = interp1(f, Px, f_common, 'linear', 0);   % spectrum of x1 on common grid
     p = Pxc / sum(Pxc);         % spectral PDF
     F = cumsum(p);               % CDF of spectrum of x1

end