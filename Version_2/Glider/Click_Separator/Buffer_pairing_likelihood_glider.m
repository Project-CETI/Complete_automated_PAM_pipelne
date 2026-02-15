function L=Buffer_pairing_likelihood_glider(Features,P)

    %% input Features: [ICI, Orientation, AoA]
    constraint_flag=0;
    for j=1:3
        x=Features(j);
        if j==2
            objA=P.Buffer_Params.Orientation.object;
            N_val=P.Buffer_Params.Orientation.normalize;
        elseif j==1
            objA=P.Buffer_Params.ICI.object;
            N_val=P.Buffer_Params.ICI.normalize;
        elseif j==3
           objA = makedist('Normal', 'mu', P.mu_buffer, 'sigma', P.sigma_buffer);
           N_val=P.N_val; 
           constraint_flag=x>P.max_AoA_change_buffers; 
        end
        GMM(j)=P.F_weights_buffer(j)*pdf(objA,x)/N_val;
    end
    L=sum(GMM);
    if constraint_flag
        L=eps;
    end
end


