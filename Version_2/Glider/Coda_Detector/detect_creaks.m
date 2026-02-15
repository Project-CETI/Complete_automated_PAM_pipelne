function Creaks=detect_creaks(Locs,Pks,ICI_Max_creaks,rank,MAD_threshold,Creaks_Amp_threshold)
%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2024
%   DESCRIPTION:

%   This function gets a vector of arrival times and avector of peak amplitudes 
%   of M transients and outputs a vector containing the indices of suspected sperm whale creaks 
%   Note: this is an optional function based on a hueristic approach which is not described
%   in the associated paper. This approach searches a sequence of high
%   rhyrhm clicks of roughly similar peak amplitudes.

%   INPUT:
%   > Locs                  - Vector of 1XM with time of arrival in seconds for M identified transients
%   > Pks                   - Vector of 1XM containing the peaks of M identified transients
%   > rank                  - Scalar representing the max size for creaks candidate clusters
%   > ICI_Max_creaks        - Scalar representing the max ICI for a sequence of creaks
%   > MAD_threshold         - Scalar representing the MAD threshold for outliers removal
%   > Creaks_Amp_threshold  - Scalar representing the amplitude threshold for creaks detection

%   OUTPUT:
%   > Creaks            - Vector of 1XW with indices of suspected sperm whale coda clicks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Creaks=[];  

    v = 1:length(Locs);
    rank_creaks_max=rank-1;

    while(1)
        rank=rank-1;
        AllCombs = nchoosek(v,rank);
        ICI_g_max=max(diff(Locs(AllCombs),1,2),[],2);
        G_ind=find(ICI_g_max<ICI_Max_creaks);
        if ~isempty(G_ind) & rank>rank_creaks_max-1 
            break
        end
        if rank<rank_creaks_max
            break
        end
    end
        
    if ~isempty(G_ind)
        [Yamp,R_Inds] = rmoutliers_custom(Pks,MAD_threshold);
        if mean(Pks(R_Inds))-mean(Yamp)>Creaks_Amp_threshold 
            Creaks=find(R_Inds==0);
        else
            Creaks=1:length(Locs);
        end
    end
         
end
