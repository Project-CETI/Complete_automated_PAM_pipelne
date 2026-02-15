function [Detected_codas,Coda_U]=Codas_Separation(Fs,U_max_all,U_T,All_codas,Y_bpf,t_bpf,Plot_flag)

   Det_inds=find(U_max_all>U_T);
   U_dets=U_max_all(Det_inds);
   All_codas_dets=All_codas(Det_inds);
   [Detected_codas,Coda_U]=Coda_clusters_annotation(Fs,U_dets,All_codas_dets,Y_bpf,t_bpf,Plot_flag);
   Coda_U=unique(round(Coda_U,4));
   Detected_codas=fliplr(Detected_codas);
   
   
end
