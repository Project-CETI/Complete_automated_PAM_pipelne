
function [Detected_codas,Coda_U]=Coda_clusters_annotation(F_ds,U_max_all,All_codas,Y_buffer,t_buffer,Plot_flag)

     
    All_codas_save=All_codas;
    c_ind=0; Coda={}; L_intersect=[]; Coda_U=[];
    All_codas=All_codas_save;
    
    All_codas=fliplr(All_codas);
    U_max_all=fliplr(U_max_all);
    
    for i=1:size(All_codas,2)
        for j=1:size(All_codas,2)
           L_intersect(j)=length(intersect(All_codas{i},All_codas{j}));
           if j==i
               L_intersect(j)=0;
           end
        end
        
        Full_coda_ind=find(L_intersect==max(L_intersect));
        if L_intersect(Full_coda_ind(1))>1
            c_ind=c_ind+1;
            Coda(c_ind)={round(All_codas{Full_coda_ind(1)},3)'};
            Coda_U(c_ind)=U_max_all(Full_coda_ind(1));
        elseif ~isempty(All_codas{i}) && sum(L_intersect)==0
            c_ind=c_ind+1;
            Coda(c_ind)={round(All_codas{i},3)'};
            Coda_U(c_ind)=U_max_all(i);
        end
        
        
            All_codas([i Full_coda_ind(1)])={[]};
    
        
    end
    
    Detected_codas=uniquearray(Coda);
    Coda_U=unique(Coda_U);
    
    Detected_codas=fliplr(Detected_codas);
    
    
    for i=1:size(Detected_codas,2)
        Det=Detected_codas{i};
        if Plot_flag
            Y_pks=[];
            for q=1:length(Det)
               Y_pks(q)=max(Y_buffer(int32(F_ds*(Det(q)-4e-3)):int32(F_ds*(Det(q)+4e-3))));
            end
            plot(Det,Y_pks,'x','Linewidth',3)
    
        end
    end

end




