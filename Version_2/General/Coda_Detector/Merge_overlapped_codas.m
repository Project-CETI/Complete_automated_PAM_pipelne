function Separated_codas_filtred=Merge_overlapped_codas(Separated_codas,Y_filtered,Fs,plot_flag)

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
     Separated_codas_filtred= Separated_codas;

    for i=1:length(Separated_codas_filtred)
         Separated_codas_filtred_pks{i}=Peaks_extract(Y_filtered,Separated_codas_filtred{i},Fs);
         if plot_flag
            hold on; plot(Separated_codas_filtred{i},Separated_codas_filtred_pks{i},'*','Linewidth',2);           
         end
    end
end