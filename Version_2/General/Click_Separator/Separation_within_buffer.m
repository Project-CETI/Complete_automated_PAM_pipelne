function Detected_subtrains=Separation_within_buffer(Clicks_within_buffer,P)


    locs=Clicks_within_buffer.ToAs;
    Nd=length(locs);
    L_tot = 1e9*ones(Nd,Nd);
    P_transition=zeros(Nd,Nd);
    ICI=zeros(Nd,Nd);
    for i=1:Nd-1
       for j=i+1:Nd               
            if locs(j)-locs(i)>P.ICI_min && locs(j)-locs(i)<P.ICI_max
               ICI(i,j)= locs(j)-locs(i);
               Membership=Feature_graph(P,Clicks_within_buffer,i,j);
                P_transition(i,j)=Membership;
                L_tot(i,j)=-log(Membership);           
            end          
       end
    end

    [C,~] = do_assignment (L_tot,-log(-P.lone_p_click_separaton), 1e9);
    nchain = 0;
    chain_nr = zeros(Nd,1);
    for i = 1:Nd
        j = find(C(i,1:Nd));
        if (~isempty(j))
            if (chain_nr(i) && ~any(chain_nr(j)))
                chain_nr(j) = chain_nr(i);
            else
                if(chain_nr(i)==0 && ~any(chain_nr(j)))
                    nchain = nchain + 1;
                    chain_nr(j) = nchain;
                    chain_nr(i) = nchain;
                end
            end
        end
    end
   
    %%
    El=[]; 
    for i=1:nchain+1
         ind=find(chain_nr==i);          
         if std(rmoutliers(Clicks_within_buffer.Slant_delays(ind)))>P.max_slant_delay_variance
            El=[El ind'];
         end                     
         ICI_ind=diff(locs(ind));
         if length(ind)==3 & abs(log(ICI_ind(2)/ICI_ind(1)))>P.max_ICI_consitency
            El=[El ind'];
         end      
    end
    El=unique(El);
    All_traces=chain_nr; All_traces(El)=[];
    All_traces(All_traces==0)=[];
    Detected_traces=unique(All_traces)';

    if ~isempty(Detected_traces)
         Gr=cell(1,length(Detected_traces));
        for i=Detected_traces
                Gr(i)={find(chain_nr==i)};
        end            
        Detected_subtrains= Gr(~cellfun(@isempty, Gr));
     else
         Detected_subtrains={};
     end
     Detected_subtrains = Detected_subtrains(cellfun(@(x) numel(x) >= P.min_subtrain_rank, Detected_subtrains));



         
end