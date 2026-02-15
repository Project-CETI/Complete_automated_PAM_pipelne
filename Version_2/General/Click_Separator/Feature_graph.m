function Membership=Feature_graph(P,Clicks_within_buffer,i,j)
          
        alpha_Pkk=log(Clicks_within_buffer.Pkk(j)/Clicks_within_buffer.Pkk(i));
        alpha_Slant_Delay=log(Clicks_within_buffer.Slant_delays(j)/Clicks_within_buffer.Slant_delays(i));
        Spectral = norm(Clicks_within_buffer.spectral{j} - Clicks_within_buffer.spectral{i});
        Features=[alpha_Slant_Delay alpha_Pkk Spectral];

        Mem_val=zeros(1,length(Features));
        for q=1:length(Features)
            objA=P.All_objs(q).objs;
            N_val=P.All_objs(q).N_val;
            Mem_val(q)=pdf(objA,Features(q))/N_val;
        end
       Membership=sum(P.F_weights.*Mem_val);
       
end

