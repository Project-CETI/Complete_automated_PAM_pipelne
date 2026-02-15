function [Coda_flag,U_max_all,All_codas]=Coda_presence_detect(In,All_codas,U_max_all,Y_buffer_filtered,Fs,Locs,Pks,P)


%   AUTHOR:         Guy Gubnitsky
%   DATE:           July 2025
%   DESCRIPTION:

%   This function gets a buffer of measured signal and a set of N
%   predtected transients and determines wether and which of these transients
%   are coda clicks

%   INPUT:
%   > Y_buffer_filtered            - Vector of MX1 samples of the bandpass filtered audio recording
%   > Fs                  - Scalar representing the sampling frequency.
%   > MPS_max               - Scalar representing the maximum plausible IPI [in sec] of sperm whale clicks
%   > IPI_min               - Scalar representing the minimum plausible IPI [in sec] of sperm whale clicks
%   > edge_width            - Scalar representing a window [in sec] set to avoid numerical issues near edges of analysis windows
%   > Locs                  - Vector of 1XN with time of arrival in seconds for N identified transients
%   > Pks                   - Vector of 1XN containing the peaks of N identified transients
%   > alpha2                - Scalar representing a normalizing factor to weight the penalty over the cluster’s rank
%   > alpha1                - Scalar representing a normalizing factor to weight the penalty over the cluster’s temporal likelihood
%   > C_lim                 - Scalar representing a capacity limit over the maximum matrix rank matlab can handle. Larger matrices will divided by loops.
%   > Max_caoda_size        - Scalar representing the Maximum allowed number of clicks in a coda cluster
%   > ICI_Min               - Scalar representing the Minimum allowed ICI of coda clicks
%   > ICI_Max               - Scalar representing the Maximum allowed ICI of coda clicks
%   > Consi_max             - Scalar representing the Maximum allowed of median of Consistency of coda clicks
%   > Consi_3_max           - Scalar representing the Maximum allowed of median of Consistency of coda clicks
%   > W_seg                 - Scalar representing a window [in sec] set to extract the transient waveform
%   > seg_percentage        - Scalar representing a percentage of window segment used for (for accurate capturing of coda click waveform)


%   OUTPUT:
%   > Coda_flag              - Scalar that flags the presence (1) or absence (0) of codas within the buffer
%   > Coda_clicks_ToAs       - Vector of 1XK with the arrival times of all K coda clicks identified within the buffer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   %% Features extraction       
   IPI=MPS_extract(P.MPS_max,P.IPI_min,Fs,Y_buffer_filtered,Locs,P.edge_width);  % Evaluate the IPI of each click candidate
   [Ya,Yp]=Extract_signal(Y_buffer_filtered,Locs,Fs,P.W_seg,P.seg_percentage); % Extract clicks' waveform (Ya) and peak amplitude (Yp)

   %% Calculate similarity matrix
    sim=zeros(size(Ya,2)-1,size(Ya,2)); 
    for i=1:size(Ya,2)-1
        for j=i+1:size(Ya,2)
              s1=max(abs(crosscorr(Ya(:,i),Ya(:,j),'NumLags',P.NOL)));    % Clicks similarity in terms of waveform correlation
              beta=1-(abs(Yp(i)-Yp(j))/max([Yp(i) Yp(j)]));             % Similarity of amplitudes
              gamma=1-(abs(IPI(i)-IPI(j))/max([IPI(i) IPI(j)]));        % IPI similarity
              sim(i,j)=P.rho_corr*s1+P.rho_I*beta+P.rho_IPI*gamma;            % Weighted sum of all the above simiarity measures.
        end
    end

   %% Cluster and detect codas       
   [L_hat_inds,L_hat,U_max]=Cluster_codas(sim,IPI,Locs,Pks,P); % Detecet and seperate codas
   
   %% Remove clusters whose clicks' features do not staisfy the constraints imposed on the resonant requency, fr, and the number of interpulses, P.    
   fr_score=zeros(1,length(find(U_max>P.U_T))); % A vector. Each element contains the average of the resonant frequency of each click in a detected coda

   if P.constarint_flag
       for D_inds=find(U_max>P.U_T)
           fr=zeros(1,length(L_hat_inds{D_inds}));
           counter=0;
            for q=L_hat_inds{D_inds}
                counter=counter+1;
                fr(counter)=resonance_frequency_extraction(Y_buffer_filtered,Fs,Locs(q)*Fs,IPI(q));
            end
            fr_score(D_inds)=median(fr);
       end
       El=find(fr_score<P.fr_max);
       
   else
         El=find(U_max>P.U_T);
   end
  
    if ~isempty(El)
         for p_inds=El
               C_plot=L_hat{p_inds};
               U_max_all=[U_max_all U_max(p_inds)];
               All_codas=[{In+C_plot(1,:)'} All_codas(:)'];                       
         end
         Coda_flag=1;
     else
       Coda_flag=0;
     end
      
end