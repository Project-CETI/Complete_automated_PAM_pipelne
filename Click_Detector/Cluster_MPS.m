function [C_inds,S_g_min]=Cluster_MPS(MPS_vec,Locs,Amp,P)
%   AUTHOR:         Guy Gubnitsky
%   DATE:           September 2023
%   DESCRIPTION:

%   This function gets a vector of M transients and outputs a vector
%   contains the indices of suspected sperm whale Echolocation clicks 
%   and one scalar representing a detection score. 

%   INPUT:
%   > MPS_vec                  - Vector of 1XM with MPS estimations of each identified transient.
%   > Locs                     - Vector of 1XM with time of arrival in seconds for M identified transients
%   > Amp                      - Vector of 1XM containing the amplitudes of M identified transients
%   > P.rank_click_train_max   - Scalar representing the max size for a click train cluster
%   > P.rank_click_train_min   - Scalar representing the min size for a click train cluster

%   OUTPUT:
%   > C_inds                - Vector of 1XK with indices of suspected sperm whale clicks 
%   > S_g_min               - scalar representing the utility score associated with the clustered clicks.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Clustering initialization:

    Score=100*ones(1,P.rank_click_train_max);
    MPS_input=1e3*MPS_vec;
    Corresponing_clusters={};
    All_clusters=[]; All_U=[];

%% Clustering: phase 1- ICI and consistency contraints    
    for i=P.rank_click_train_min:P.rank_click_train_max
         v = 1:length(Locs);
         AllCombs = nchoosek(v,i);
         AllCombs_bank(i).comb=AllCombs;
         ICI_mat=diff(Locs(AllCombs),1,2);
         ICI_n1=ICI_mat(:,2:end); ICI_n0=ICI_mat(:,1:end-1);
         Consi_max=max(abs(log(ICI_n1./ICI_n0)),[],2);
         ICI_g_max=max(diff(Locs(AllCombs),1,2),[],2);
         ICI_g_min=min(diff(Locs(AllCombs),1,2),[],2);
         S_g=std(MPS_input(AllCombs),1,2);
         J_g=1-JF(Amp(AllCombs));

         G_ind=find(ICI_g_min>P.ICI_Min & ICI_g_max<P.ICI_Max & Consi_max<P.Consi_max);  

        U=S_g(G_ind)+P.alpha1*exp(-i)+P.alpha2*J_g(G_ind);
        Pick_inds=find(U<3); Utility=U(Pick_inds);
        Chosen_clusters=AllCombs(G_ind(Pick_inds),:);
        Chosen_clusters_indexed=mat2inds(Chosen_clusters,length(Locs));

        All_clusters=[All_clusters ; Chosen_clusters_indexed];
        All_U=[All_U ; Utility];
    end

%% Clustering: phase 2- ortogonality contraint    

     c=0;
     v = 1:length(All_U);
     for i=1:floor(length(All_U)/2)
       NOG(i) = nchoosek(length(All_U),i);  %Number of combinations per number of groups
     end
     if length(All_U)>1
        % Nc=max(find(NOG<1081575));
        Nc=find(NOG<1081575, 1, 'last' );
     else
        Nc=1;
     end
     for i=1:Nc
         AllCombs = nchoosek(v,i);
         if i==1
            Ortogonal_inds=AllCombs;
         elseif i>1 
            M_criterion=Slice_sum(All_clusters,AllCombs,i);
            Ortogonal_inds=find(M_criterion==1);
         end
         if length(Ortogonal_inds)>1
              U_cands=1/i+sum(All_U(AllCombs(Ortogonal_inds,:)),2);
         elseif ~isempty(Ortogonal_inds)
             U_cands=1/i+sum(All_U(AllCombs(Ortogonal_inds,:)));
         else
             U_cands=[];
         end
         if ~isempty(U_cands)
             c=c+1;
             Score(c)=min(U_cands) ;
             % Corresponing_clusters(c)={All_clusters(AllCombs(Ortogonal_inds(find(U_cands==Score(c))),:)',:)};
             Corresponing_clusters(c)={All_clusters(AllCombs(Ortogonal_inds(U_cands==Score(c)),:)',:)};
         else
             c=c+1;
             Score(c)=100;
         end
     end

%% Clustering: phase 3- verification (spectrogram-likelihood contraint)    

    C_inds=[];    
    S_g_min=min(Score);
    if S_g_min<100
        Chosen_bank=cell2mat(Corresponing_clusters(Score==S_g_min));
        for i=1:size(Chosen_bank,1)
            C_inds=[C_inds find(Chosen_bank(i,:)==1)]; 
            C_modified=find(Chosen_bank(i,:)==1);
            S_g_min_cl(i)=std(MPS_input(C_modified))+P.alpha1*exp(-length(C_modified))+P.alpha2*(1-JF(Amp(C_modified)));
        end
        C_inds=unique(C_inds);
        S_g_min=1/i+sum(S_g_min_cl);
    end

  
        
end
