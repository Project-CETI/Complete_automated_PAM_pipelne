function Separated_codas_filtred=Remove_mutipath(Separated_codas,Y_filtered,Fs,plot_flag)

     merge_idx=[];
     for i=1:length(Separated_codas)-1
            test=ismember(Separated_codas{i},Separated_codas{i+1});
            if sum(test)/length(test)>=0.5
                 merge_idx=[merge_idx i];
            end
     end

     for i=1:length(merge_idx)
         Separated_codas(merge_idx(i)+1)={unique([Separated_codas{merge_idx(i)} Separated_codas{merge_idx(i)+1}])};
     end

     Separated_codas(merge_idx)=[];


    Th_dist=35e-3;
    Separated_codas_filtred={};
    All_parings=[];
    All_dists=[];
    for coda_idx=1:length(Separated_codas)
        ToAs_ref=Separated_codas{coda_idx};
         Coda_dist=[];
         Coda_pair=[];
        for coda_compare=1:length(Separated_codas)
            if coda_compare~=coda_idx
                ToAs_compare=Separated_codas{coda_compare};
                if ToAs_compare(1)-ToAs_ref(1)<0.1
                    if length(ToAs_ref)<=length(ToAs_compare)
                        All_dist=zeros(1,length(ToAs_ref));
                        for i=1:length(ToAs_ref)
                            [dist,~]=min(abs(ToAs_ref(i)-ToAs_compare));
                            if dist<Th_dist
                                All_dist(i)=dist;
                            end
                        end
                        Coda_dist=[Coda_dist ; mean(All_dist)];
                        Coda_pair=[Coda_pair ; [coda_idx coda_compare]];
                    else
                        if length(ToAs_ref)>length(ToAs_compare)
                            All_dist=zeros(1,length(ToAs_compare));
                            for i=1:length(ToAs_compare)
                                [dist,~]=min(abs(ToAs_ref-ToAs_compare(i)));
                                if dist<Th_dist
                                    All_dist(i)=dist;
                                end
                            end
                            Coda_dist=[Coda_dist ; mean(All_dist)];
                            Coda_pair=[Coda_pair ; [coda_idx coda_compare]];                    
                        end
                    end
                end
            end
        end

        remove_null_idx=Coda_dist==0;
        Coda_dist(remove_null_idx)=[];
        Coda_pair(remove_null_idx,:)=[];
        if min(Coda_dist)<Th_dist
            pair_candidate=find(Coda_dist==min(Coda_dist));
            All_parings=[All_parings ; Coda_pair(pair_candidate,:)];
            All_dists=[All_dists ; ones(length(pair_candidate),1)*min(Coda_dist)];
        end
    end

    [All_groups,pairings_inds]=unique(sort(All_parings,2,"ascend"),"rows");
    All_groups_dists=All_dists(pairings_inds);

    Unique_groups=unique(All_groups(:,1));
    final_pairings=[];
    for i=1:length(Unique_groups)
        Min_dist=find(min(All_groups_dists(All_groups(:,1)==Unique_groups(i))));
        Cands=All_groups(All_groups(:,1)==Unique_groups(i),:);
        final_pairings=[final_pairings ; Cands(Min_dist,:)];
    end

     for i=1:size(final_pairings,1)
        locs_1=Separated_codas{final_pairings(i,1)}; 
        locs_2=Separated_codas{final_pairings(i,2)}; 

        pks_1=Peaks_extract(Y_filtered,locs_1,Fs);
        pks_2=Peaks_extract(Y_filtered,locs_2,Fs);

        if mean(pks_2)>mean(pks_1)
            Separated_codas_filtred(i)={locs_2};
            Separated_codas_filtred_pks(i)={pks_2};              
        else
            Separated_codas_filtred(i)={locs_1};
            Separated_codas_filtred_pks(i)={pks_1};
        end

     end

     Separated_codas_filtred=[Separated_codas_filtred Separated_codas(find(~ismember(1:length(Separated_codas),All_groups)==1))];

     merge_idx=[];
     for i=1:length(Separated_codas_filtred)-1
            test=ismember(Separated_codas_filtred{i},Separated_codas_filtred{i+1});
            if sum(test)/length(test)>=0.5
                 merge_idx=[merge_idx i];
            end
     end
     for i=1:length(merge_idx)
         Separated_codas_filtred(merge_idx(i)+1)={unique([Separated_codas_filtred{merge_idx(i)} Separated_codas_filtred{merge_idx(i)+1}])};
     end

     Separated_codas_filtred(merge_idx)=[];

     for i=1:length(Separated_codas_filtred)
         Separated_codas_filtred_pks{i}=Peaks_extract(Y_filtered,Separated_codas_filtred{i},Fs);
         if plot_flag
            hold on; plot(Separated_codas_filtred{i},Separated_codas_filtred_pks{i},'*','Linewidth',2);           
         end
     end

end


