function Separated_codas=Coda_Detector(Y_filtered,Fs,P,Click_detections,Separated_Clicks,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           November 2025
%   DESCRIPTION:

%   This function gets a signal with echolocation click detections 
%   and separates and attributes the clicks to different source whales. 

%   INPUT:
%   > Y_filtered               - Vector of MX1 comprising the band-pass filtered 1 channel of M samples of a buffered audio
%   > Click_Detections         - Struct containing the arrival times and amplitudes of pre-detected clicks 
%   > Separated_whales         - Struct containing the arrival times and amplitudes of the clicks associated with each whale
%   > Fs                       - Scalar representing the sampling frequency.
%   > P                        - Struct containing the detector parameters
%   > Plot_flag                - Flag for visualizing results


%   OUTPUT:
%   > Separated_codas         - Cell array containing the arrival times of the clicks of each deteted coda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Variable initialization 
    
    All_codas={[]}; % An array of cells where each element is a vector contating the arrival time [in seconds] of the clicks of a detected coda
    U_max_all=[];   % A vector indicating the likelihood score [ranges between 0 and 1] of each detected group of coda clicks


    %% Remove detected echolocation clicks before coda analysis
    Echolocation_clicks.ToAs=[];
    Echolocation_clicks.Amps=[];
    for whale_id=1:length(Separated_Clicks)
      Echolocation_clicks.ToAs=[Echolocation_clicks.ToAs Separated_Clicks(whale_id).ToAs'];
      Echolocation_clicks.Amps=[Echolocation_clicks.Amps Separated_Clicks(whale_id).Amps];
    end

    Non_echolocation_clicks_idx=~ismember(Click_detections.ToAs,Echolocation_clicks.ToAs);
    Non_echolocation_clicks.ToAs=Click_detections.ToAs(Non_echolocation_clicks_idx);
    Non_echolocation_clicks.Amps=Click_detections.Amps(Non_echolocation_clicks_idx);

    %% Spectral filtering:
    Coda_candidates.ToAs=[];
    Coda_candidates.Amps=[];
    Coda_candidates_idx=[];
    for i=1:length(Non_echolocation_clicks.ToAs)
        CDF_est=Spectral_features_extraction(Y_filtered,Fs,Fs*Non_echolocation_clicks.ToAs(i),P.pulse_width);
        if CDF_est(P.freq_test_idx)>P.CDF_test_threshold
           Coda_candidates_idx=[Coda_candidates_idx i];
        end
    end
    
    if ~isempty(Coda_candidates)
        Coda_candidates.ToAs=Non_echolocation_clicks.ToAs(Coda_candidates_idx);
        Coda_candidates.Amps=Non_echolocation_clicks.Amps(Coda_candidates_idx);
    else
        Coda_candidates=Non_echolocation_clicks;
    end

    In=P.In; % initialize moving window 
    Coda_count=P.Coda_count; % initialize detection counter

    %% Process over buffers    
    while(int32((In+P.Buffer_size)*Fs)<length(Y_filtered))
        %% Extract a buffer from the audio stream
        Y_buffer_filtered=Y_filtered(int32(In*Fs)+1:int32((In+P.Buffer_size)*Fs));   % Extract data from chosen buffer

        %% Transient selection
        t1=In; t2=In+P.Buffer_size;
        Locs=Click_detections.ToAs(Coda_candidates.ToAs>t1 & Coda_candidates.ToAs<t2);
        Pks=Click_detections.Amps(Coda_candidates.ToAs>t1 & Coda_candidates.ToAs<t2);               
        
        % Pick most the NOT most intense transients
        if length(Pks)>P.NOT
           [Pks,I] = maxk(Pks,P.NOT);
           Locs=Locs(I);
        end       
       
        % Sort detections by time of arrival       
        [Locs,LI]=sort(Locs);
        Pks=Pks(LI);


        locs_buffer=Locs-t1;

        El_inds=P.W_seg;
        Pks(locs_buffer<El_inds | locs_buffer>(P.Buffer_size-El_inds))=[];
        locs_buffer(locs_buffer<El_inds | locs_buffer>(P.Buffer_size-El_inds))=[];
   

        if length(Locs)>P.transients_threshold
            %% Coda presence detection
            [Coda_flag,U_max_all,All_codas]=Coda_presence_detect(In,All_codas,U_max_all,Y_buffer_filtered,Fs,locs_buffer,Pks,P);
        else
            Coda_flag=0;
        end
        In=In+P.overlap_size;
        Coda_count=Coda_count+Coda_flag;

    end

    U_max_all=fliplr(U_max_all);

    t_filtered=(0:1/Fs: (1/Fs)*(length(Y_filtered)-1))';
    if Coda_count>P.Coda_count_threshold
        if Plot_flag.Coda_detection
            figure; plot(t_filtered,Y_filtered); grid on; hold on; title(['Codas present (' num2str(Coda_count) ')']);
        end
        [Separated_codas,~]=Codas_Separation(Fs,U_max_all,P.U_T,All_codas,Y_filtered,t_filtered,Plot_flag.Coda_detection); % Plot coda detections
    else
        if Plot_flag.Coda_detection
           figure; plot(t_filtered,Y_filtered); grid on; title(['Codas absent (' num2str(Coda_count) ')']);
        end
        Separated_codas={[]};
    end
    
end
    



