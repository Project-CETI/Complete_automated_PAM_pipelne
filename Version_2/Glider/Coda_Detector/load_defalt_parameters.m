function P=load_defalt_parameters

%% Parameters settings:
    P.creaks_flag=1;              % Optional: set 1 to ignore potential creaks | set 0 for normal operation
    P.pulse_width=5;              % Define pulse width in [ms]
    P.U_T=0.6;                    % Coda Detection threshold
    P.MPS_max=5e-3;               % Set the maximum plausible IPI of sperm whale clicks
    P.IPI_min=1.8e-3;             % Set the minimum plausible IPI of sperm whale clicks
    P.SNR_thresh=54;              % Min SNR threshold [in dB]
    P.SNR_window=0.1;             % window size [in sec] for SNR estimation of transient signals 
    P.crop_window=3e-3;           % window size [in sec] for analyzing the noise levels around candidate transients
    P.Buffer_size=3;              % Set buffer size [sec]
    P.rho_corr=0.4;               % normalizing weight for correelation similarity factor 
    P.rho_IPI=0.3;                % normalizing weight for IPI similarity factor 
    P.rho_I=0.3;                  % normalizing weight for intensity similarity factor 
    P.transients_threshold=2;     % minimum number of transient detections for considering further processing
    P.In=0;                       % Initialize Buffer index
    P.Coda_count=0;               % Initialize coda detections counter
    P.overlap_size=1;             % define step size of the analysis sliding window [sec]
    P.fr_max=9.8;                 % maximum allowed resonant frequency [kHz]
    P.NOT=20;                     % maximum allowed number of transients in a buffer
    P.edge_width=0.9e-3;          % set window [in sec] to avoid numerical issues near edges of analysis windows
    P.W_seg=16e-3;                % set window segment size [in sec] for waveform extraction
    P.seg_percentage=0.12;        % set window segment percentage for waveform extraction (for accurate capturing of coda click waveform)
    P.NOL=150;                    % set number of lags for corelation computations
    P.alpha2=15;                  % Normalizing factor to weight the penalty over the cluster’s rank
    P.alpha1=1e3;                 % Normalizing factor to weight the penalty over the cluster’s temporal likelihood
    P.C_lim=1e5;                  % Capacity limit- limit over the maximum matrix rank matlab can handle. Larger matrices will divided by loops.
    P.Max_caoda_size=8;           % Set Mximum allowed number of clicks in a coda cluster
    P.ICI_Min=0.05;               % Minimum allowed ICI of coda clicks
    P.ICI_Max=0.6;                % Maximum allowed ICI of coda clicks
    P.chanel_idx_detection=1;     % choose channel for coda detection
    P.chanel_idx_verification=2;  % choose channel for coda verification
    P.Coda_count_threshold=3;     % save threshold - save in memory if the number of detected coda buffers exceeds this thrshold 
    P.rank_creaks=10;             % Set a max size for creaks candidate clusters (Note that ranks higher than 10 may cause complexity issues)
    P.ICI_Max_creaks=0.06;        % Set max ICI for a sequence of creaks
    P.MAD_threshold=3;            % Set the MAD threshold for outliers removal
    P.Creaks_Amp_threshold=0.25;  % Set amplitude threshold for creaks detection
    P.CDF_right_threshold=0.92;   % Right hand CDF Threshold to filter out non-coda clicks from subsequent analysis
    P.CDF_left_threshold=0.32;    % Left hand CDF Threshold to filter out non-coda clicks from subsequent analysis
    P.freq_right_idx=480;         % Frequency index of the right hand CDF threshold point
    P.freq_left_idx=64;           % Frequency index of the left hand CDF threshold point
    P.fmax = 24e3;                % Maximal frequency for CDF calculation
    P.Nf = 1e3;                   % Spectral resolution for CDF calculation

    P.Coda_ICI_thresh_max=0.4;
    P.Coda_ICI_thresh_min=0.1;

    P.Consi_max=[0 0 1 0.83 0.65 0.5 0.63 0.5 0.71 0.4];    % Maximum allowed of median of Consistency of coda clicks
    P.Consi_3_max=[0 0 1 0.8 0.7 0.93 0.99 0.83 1.1 0.74];  % Maximum allowed of median of Consistency of coda clicks
    P.Coda_count_threshold=3;                               % Coda presence threshold - declare the presence of codas in a buffer if the number of detected codas exceeds this threshold 
    P.constarint_flag=0;                                    % Apply contraints: set 1 for Yes | set 0 for No

%% GGMM pre-estimated parameters
%% EigV:
P.EigV(1)={[]}; 
P.EigV(2)={[]};
P.EigV(3)={[0.7667 -0.642 ; 0.642 0.7667]};
P.EigV(4)={[0.4767 0.8523 ; 0.6129 -0.1465 ; 0.6302 -0.5022]};
P.EigV(5)={[0.6768 -0.3423 ; 0.6319 -0.1837 ; 0.2666 0.6265 ; 0.2676 0.6756]};
P.EigV(6)={[0.5688 0.5985 ; 0.5039 0.2874 ; 0.3874 -0.4253 ; 0.3607 -0.4497 ; 0.3772 -0.4197]};
P.EigV(7)={[0.7757 -0.5097 ; 0.4542 0.1635 ; 0.2697 0.2150 ; 0.2378 0.3287 ; 0.1877 0.4768 ; 0.1658 0.5761]};
P.EigV(8)={[0.6702 -0.4319 ; 0.4885 -0.3301 ; 0.2444  0.3538 ; 0.2478 0.5526 ; 0.2328 0.3030 ; 0.2334 0.3069 ; 0.2872  0.2965]};
P.EigV(9)={[0.5700 0.5875 ; 0.4274 0.3649 ; 0.2826 -0.3227 ; 0.2705 -0.3536 ; 0.2854 -0.3284 ; 0.2826 -0.3008 ; 0.2801 -0.2562 ; 0.3158 -0.1694]};
P.EigV(10)={[0.4450 -0.2361 ; 0.3667 -0.0657 ; 0.2393 -0.1648 ; 0.2485 -0.1386 ; 0.5290 0.7907 ; 0.2959 -0.0759 ; 0.2497 -0.1015 ; 0.2206 -0.2120 ; 0.2649 -0.4555]};

%% EigV_3D:
P.EigV_3D(1) = {[]};
P.EigV_3D(2) = {[]};
P.EigV_3D(3) = {[]};
P.EigV_3D(4) = {[0.4857 0.8466 -0.2177; 0.6180 -0.1565 0.7705; 0.6182 -0.5088 -0.5992]};
P.EigV_3D(5) = {[0.6744 -0.3462 -0.6477; 0.6303 -0.1894 0.7443; 0.2723 0.6188 0.0387; 0.2715 0.6792 -0.1578]};
P.EigV_3D(6) = {[0.6139 0.5774 -0.3885; 0.5249 0.2056 0.6294; 0.3595 -0.4110 -0.5137; 0.3124 -0.4836 -0.1550; 0.3475 -0.4706 0.4063]};
P.EigV_3D(7) = {[0.7570 -0.5361 -0.1234; 0.4536 0.1082 0.6704; 0.2842 0.2551 -0.5873; 0.2544 0.3472 -0.3271; 0.2050 0.4701 -0.0606; 0.1836 0.5425 0.2825]};
P.EigV_3D(8) = {[0.6088 0.5620 -0.2129; 0.4551 0.3134 0.1555; 0.2856 -0.2786 -0.1351; 0.3038 -0.4828 -0.5956; 0.2795 -0.3227 0.0039; 0.2728 -0.3196 0.2012; 0.3094 -0.2625 0.7190]};

%% Params3D_rev:
P.Params3D_rev(1).m = [];
P.Params3D_rev(1).Z_max = [];
P.Params3D_rev(1).Beta = [];
P.Params3D_rev(1).mu = [];
P.Params3D_rev(1).Sigma = [];

P.Params3D_rev(2).m = [];
P.Params3D_rev(2).Z_max = [];
P.Params3D_rev(2).Beta = [];
P.Params3D_rev(2).mu = [];
P.Params3D_rev(2).Sigma = [];

P.Params3D_rev(3).m = [];
P.Params3D_rev(3).Z_max = [];
P.Params3D_rev(3).Beta = [];
P.Params3D_rev(3).mu = [];
P.Params3D_rev(3).Sigma = [];

P.Params3D_rev(4).m = [0.000688356 7.516366e-08 1.023794e-05 7.243554e-05 0.000466727];
P.Params3D_rev(4).Z_max = [5500.2417 534159.5870 125436.6817 22487.9251 10130.9192];
P.Params3D_rev(4).Beta = [1.0278820 0.3156231 0.5069399 0.5154429 0.5562203];
P.Params3D_rev(4).mu = [
    0.4004953 0.1982000 -0.0381126;
    0.2127915 0.1528772 -0.0319830;
    0.2896748 0.1284209  0.0014551;
    0.1449874 0.0061985 -0.0128148;
    0.5674438 0.0684631 -0.0157405];
P.Params3D_rev(4).Sigma = {
    [1.3007237 0.7411217 -0.0200827; 0.7411217 1.2828545 -0.1302233; -0.0200827 -0.1302233 0.4164218];
    [0.9275163 0.1994645 0.0077220; 0.1994645 1.3467656 -0.1797635; 0.0077220 -0.1797635 0.7257181];
    [1.1714598 0.1120298 0.0406286; 0.1120298 0.8571423 -0.1368296; 0.0406286 -0.1368296 0.9713979];
    [2.1704457 0.6073654 -0.0481340; 0.6073654 0.6343657 0.1326394; -0.0481340 0.1326394 0.1951886];
    [2.7496871 0.6243711 0.0026781; 0.6243711 0.2101097 0.0183443; 0.0026781 0.0183443 0.0402032]};

P.Params3D_rev(5).m = [0.0044769 0.0001023 2.983681e-05 0.0004076 0.0001130 0.0001136 2.983681e-05 8.520989e-06 5.914938e-05 0.0001667];
P.Params3D_rev(5).Z_max = [1488.4737 28445.7226 36437.6645 40875.6110 18119.6518 117930.1837 36437.6645 189136.7346 65542.1698 22657.6877];
P.Params3D_rev(5).Beta = [0.9100859 0.6475028 0.4819368 0.6631780 0.6834184 1.0174514 0.4819368 0.5134571 0.7279819 0.5262197];
P.Params3D_rev(5).mu = [
    0.5642269 0.0371414 0.0055354;
    0.2736752 0.1987789 0.0982617;
    0.3305024 0.1852125 -0.0117328;
    0.8731533 0.3505096 -0.0130762;
    0.3162657 0.0702599 -0.0192632;
    0.0655048 0.0520529 -0.0013832;
    0.3305024 0.1852125 -0.0117328;
    0.1608547 0.0429937 -0.0008042;
    0.2352525 0.0983364 0.0033179;
    0.5367429 0.2305925 -0.0086721];
P.Params3D_rev(5).Sigma = {
    [2.8124236 -0.3469818 -0.0367397; -0.3469818 0.1313893 0.0197973; -0.0367397 0.0197973 0.0561871];
    [0.5755062 -0.2007480 0.6230000; -0.2007480 0.8908887 -0.6074168; 0.6230000 -0.6074168 1.5336051];
    [0.8730153 0.9521483 0.1507187; 0.9521483 1.5666783 0.1725740; 0.1507187 0.1725740 0.5603064];
    [2.5481530 0.9870723 0.0940326; 0.9870723 0.4184516 0.0471493; 0.0940326 0.0471493 0.0333954];
    [1.3396889 0.2854888 -0.1589494; 0.2854888 0.9578444 0.1381511; -0.1589494 0.1381511 0.7024668];
    [1.2235799 0.8888536 0.1350512; 0.8888536 1.6135087 0.1200937; 0.1350512 0.1200937 0.1629114];
    [0.8730153 0.9521483 0.1507187; 0.9521483 1.5666783 0.1725740; 0.1507187 0.1725740 0.5603064];
    [1.1440783 -0.3037634 -0.2154880; -0.3037634 0.8028588 -0.0092273; -0.2154880 -0.0092273 1.0530629];
    [1.4081427 0.4409519 0.1387544; 0.4409519 0.9404236 0.2489370; 0.1387544 0.2489370 0.6514337];
    [2.5494140 0.8852606 -0.0227013; 0.8852606 0.3949649 0.0030562; -0.0227013 0.0030562 0.0556212]};

P.Params3D_rev(6).m = [0.0111655 0.0042541 0.0020292 0.0015569 0.0002316];
P.Params3D_rev(6).Z_max = [326.1105 1554.7757 2065.3133 7703.8316 12520.4137];
P.Params3D_rev(6).Beta = [3.1506625 1.4026368 1.8830380 0.7751998 0.6200402];
P.Params3D_rev(6).mu = [
    0.6283686 0.0908232 0.0514498;
    0.4037771 0.0278826 -0.0434873;
    0.4463505 -0.0288288 0.0372893;
    0.6279289 -0.1695038 -0.0063566;
    0.1609036 -0.0385973 0.0077080];
P.Params3D_rev(6).Sigma = {
    [2.0480268 0.3620045 0.0603495; 0.3620045 0.7762543 0.0047841; 0.0603495 0.0047841 0.1757189];
    [1.8953866 0.7540511 -0.8305235; 0.7540511 0.5869937 -0.4285874; -0.8305235 -0.4285874 0.5176198];
    [0.9704681 -0.2084863 0.1602229; -0.2084863 1.3365795 -0.5142258; 0.1602229 -0.5142258 0.6929525];
    [2.7553458 -0.6232736 -0.0881572; -0.6232736 0.2013422 -0.0075479; -0.0881572 -0.0075479 0.0433121];
    [2.4355006 0.1678014 -0.0053965; 0.1678014 0.4488872 -0.1197456; -0.0053965 -0.1197456 0.1156123]};

P.Params3D_rev(7).m = [0.0025891 0.0022230 0.0038531 0.0015422 1.3141e-05];
P.Params3D_rev(7).Z_max = [4373.5115 4742.6714 1122.4131 2364.0939 39696.6650];
P.Params3D_rev(7).Beta = [0.7913215 1.5765470 11.0467259 1.3044985 0.3956320];
P.Params3D_rev(7).mu = [
    0.5287325 0.2808968 -0.0326960;
    0.5626703 0.0250269 -0.0455544;
    0.4113169 0.0962148 -0.0015014;
    0.6686523 0.0697392 0.1296866;
    0.1204799 0.0826973 -0.0010298];
P.Params3D_rev(7).Sigma = {
    [2.1249077 1.2449968 -0.2966143; 1.2449968 0.8118233 -0.1816059; -0.2966143 -0.1816059 0.0632690];
    [2.6038364 -0.0610858 -0.4536748; -0.0610858 0.1474274 0.0227965; -0.4536748 0.0227965 0.2487362];
    [1.3133443 -0.0085292 -0.4813556; -0.0085292 0.7888627 -0.0407734; -0.4813556 -0.0407734 0.8977931];
    [1.7038430 0.2364260 0.1600116; 0.2364260 0.8806384 0.2502216; 0.1600116 0.2502216 0.4155185];
    [1.9340373 0.7348103 0.0210414; 0.7348103 0.9641545 0.1283303; 0.0210414 0.1283303 0.1018082]};

P.Params3D_rev(8).m = [0.0110865 0.0016983 1.5661e-06];
P.Params3D_rev(8).Z_max = [368.3452 1402.7084 113510.1434];
P.Params3D_rev(8).Beta = [4.1536408 0.8350618 0.3455298];
P.Params3D_rev(8).mu = [
    0.6078362 0.1116256 2.5675e-06;
    0.4955485 -0.1036021 0.0305775;
    0.1277191 -0.0456241 0.0212359];
P.Params3D_rev(8).Sigma = {
    [1.7752408 0.3007071 0.4886348; 0.3007071 0.5232687 0.4501238; 0.4886348 0.4501238 0.7014905];
    [1.6417626 -0.6823670 0.1274177; -0.6823670 1.0016502 -0.4306011; 0.1274177 -0.4306011 0.3565872];
    [1.9508307 -0.2701039 0.3464572; -0.2701039 0.3947624 -0.3131486; 0.3464572 -0.3131486 0.6544069]};

%% Params:

P.Params(1).m = [];
P.Params(1).Z_max = [];
P.Params(1).Beta = [];
P.Params(1).mu = [];
P.Params(1).Sigma = [];

P.Params(2).m = [];
P.Params(2).Z_max = [];
P.Params(2).Beta = [];
P.Params(2).mu = [];
P.Params(2).Sigma = [];

P.Params(3).m = [4.60977e-05 1.07778e-05];
P.Params(3).Z_max = [649.335 3585.15];
P.Params(3).Beta = [0.457416 0.47277];
P.Params(3).mu = [0.231625 0.0342189; 0.089297 0.0433115];
P.Params(3).Sigma = {[0.901713 0.365611; 0.365611 1.09829], [1.47487 0.436247; 0.436247 0.525127]};

P.Params(4).m = [0.000468873 4.68401e-07 1.73734e-05 0.000904387 0.00147879];
P.Params(4).Z_max = [276.298 6665.02 1563.57 189.816 159.407];
P.Params(4).Beta = [0.819251 0.348072 0.527923 0.882068 0.644572];
P.Params(4).mu = [0.408932 0.207178; 0.210647 0.155856; 0.287595 0.132945; 0.145457 0.00952851; 0.559612 0.0764958];
P.Params(4).Sigma = {
    [0.667605 0.3117; 0.3117 1.3324],
    [0.738631 0.138265; 0.138265 1.26137],
    [1.14198 0.104349; 0.104349 0.85802],
    [1.45711 0.424854; 0.424854 0.542893],
    [1.81995 0.474375; 0.474375 0.180047]
};

P.Params(5).m = [0.0129506 0.00014981 1.20391e-05 0.00013572 0.000489096];
P.Params(5).Z_max = [94.3549 733.47 2768.28 1079.28 336.213];
P.Params(5).Beta = [1.36889 0.758106 0.520641 0.890254 0.577745];
P.Params(5).mu = [0.563777 0.0432994; 0.271532 0.201695; 0.160372 0.0447669; 0.234184 0.100845; 0.534212 0.23641];
P.Params(5).Sigma = {
    [1.90721 -0.200804; -0.200804 0.0927905],
    [0.800506 -0.23671; -0.23671 1.19949],
    [1.17534 -0.318436; -0.318436 0.824662],
    [1.19257 0.372554; 0.372554 0.80743],
    [1.71701 0.615394; 0.615394 0.282993]
};

P.Params(6).m = [0.00631464 0.000759692];
P.Params(6).Z_max = [93.8846 167.841];
P.Params(6).Beta = [1.20977 0.737854];
P.Params(6).mu = [0.650384 -0.00792046; 0.165503 -0.00248084];
P.Params(6).Sigma = {
    [1.94025 0.109774; 0.109774 0.0597533],
    [1.49487 0.358802; 0.358802 0.505132]
};

P.Params(7).m = [0.00945227 0.0038293 0.00155987 0.0044006 8.45253e-05];
P.Params(7).Z_max = [34.9971 142.96 125.153 102.638 363.016];
P.Params(7).Beta = [3.32128 4.30804 1.15919 1.7025 0.447981];
P.Params(7).mu = [0.412544 0.127184; 0.566281 0.0419207; 0.665625 0.113626; 0.521715 0.303362; 0.1198 0.0889468];
P.Params(7).Sigma = {
    [0.55032 -0.200605; -0.200605 1.44968],
    [1.83891 -0.0215091; -0.0215091 0.161086],
    [1.24923 0.218798; 0.218798 0.750771],
    [1.43049 0.733703; 0.733703 0.569507],
    [1.24917 0.553089; 0.553089 0.75083]
};

P.Params(8).m = [0.00411139 0.000242083 2.78562e-06];
P.Params(8).Z_max = [68.3481 96.4809 1952.92];
P.Params(8).Beta = [1.68153 0.437021 0.335864];
P.Params(8).mu = [0.671943 0.0514116; 0.491058 -0.12391; 0.121755 -0.0617474];
P.Params(8).Sigma = {
    [1.34178 -0.421367; -0.421367 0.658224],
    [0.722282 0.0469206; 0.0469206 1.27772],
    [1.52442 -0.356511; -0.356511 0.475585]
};

P.Params(9).m = [0.00105113 1.59651e-05];
P.Params(9).Z_max = [91.3401 1003.61];
P.Params(9).Beta = [0.695818 0.38877];
P.Params(9).mu = [0.499855 -0.0275201; 0.14061 -0.0332814];
P.Params(9).Sigma = {
    [1.07372 -0.287695; -0.287695 0.926276],
    [1.74659 -0.308426; -0.308426 0.253409]
};

P.Params(10).m = [0.000578933 2.22383e-05];
P.Params(10).Z_max = [144.149 598.131];
P.Params(10).Beta = [0.666843 0.360063];
P.Params(10).mu = [0.530723 -0.0348163; 0.147795 -0.0366855];
P.Params(10).Sigma = {
    [0.866151 0.103351; 0.103351 1.13385],
    [1.73882 -0.314986; -0.314986 0.261178]
};



end