function Membership=Feature_graph(P,Clicks_within_buffer,i,j)
        
   
        alpha_Pkk=log(Clicks_within_buffer.Pkk(j)/Clicks_within_buffer.Pkk(i));
        Spectral = norm(Clicks_within_buffer.spectral{j} - Clicks_within_buffer.spectral{i});
        AoA_vec_i=[Clicks_within_buffer.whale_bearing(i) Clicks_within_buffer.whale_elevation(i)];
        AoA_vec_j=[Clicks_within_buffer.whale_bearing(j) Clicks_within_buffer.whale_elevation(j)];
        alpha_AoA=norm(AoA_vec_j-AoA_vec_i);
        Features=[alpha_AoA alpha_Pkk Spectral];
        Mem_val=zeros(1,length(Features));

       for q=1:length(Features)
            if q==1
                Mem_val(q)=(1/(0.08*P.sigma*sqrt(2*pi))) * exp(-0.5 * ((alpha_AoA - P.mu)/P.sigma).^2);
            else
                objA=P.All_objs(q-1).objs;
                N_val=P.All_objs(q-1).N_val;
                Mem_val(q)=pdf(objA,Features(q))/N_val;
            end
       end
       Membership=sum(P.F_weights.*Mem_val);

end

