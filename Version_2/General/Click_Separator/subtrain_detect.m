function Detected_subtrains=subtrain_detect(ref_ToAs,F_weights,locs,buffer,F_ds,All_objs,mode)


    %% Feature extraction
    if size(buffer,2)==1
        buffer=buffer';
    end

    W=3e-3; roi=[5e-3 15e-3]; %roi=[5e-3 18e-3];
    Click=[]; Click_multi=[]; EnV=[]; Noise=[];
    Click_multi_L1=length(buffer(int32((locs(1)-roi(1))*F_ds):int32((locs(1)+roi(2))*F_ds)));
    for iter=1:length(locs)   
         Click(iter,:)=buffer(int32((locs(iter)-W)*F_ds):int32((locs(iter)+W)*F_ds));
         Click_multi_tmp=buffer(int32((locs(iter)-roi(1))*F_ds):int32((locs(iter)+roi(2))*F_ds));
         if Click_multi_L1==length(Click_multi_tmp)
             Click_multi(iter,:)=Click_multi_tmp;
         elseif Click_multi_L1<length(Click_multi_tmp)
             Click_multi(iter,:)=Click_multi_tmp(1:Click_multi_L1);
         elseif Click_multi_L1>length(Click_multi_tmp)
             Click_multi_tmp2=zeros(1,Click_multi_L1);
             Click_multi_tmp2(1:length(Click_multi_tmp))=Click_multi_tmp;
             Click_multi(iter,:)=Click_multi_tmp2;
         end

         Slant_Delay(iter)=estimate_slant_delays(Click_multi(iter,:),F_ds);
    end

    %%
    ICI_min=0.4; 
    ICI_max=2.5; 
    Nd=length(locs);
    L_tot = 1e9*ones(Nd,Nd);
    P_transition=zeros(Nd,Nd);
    ICI=zeros(Nd,Nd);
    for i=1:Nd-1
       for j=i+1:Nd               
            if locs(j)-locs(i)>ICI_min && locs(j)-locs(i)<ICI_max
               ICI(i,j)= locs(j)-locs(i);
                [~,~,~,Membership]=extract_click_pair_features_V3(F_weights,ICI(i,j),Click(i,:),Click(j,:),Click_multi(i,:),Click_multi(j,:),F_ds,All_objs); 
                P_transition(i,j)=Membership;
                L_tot(i,j)=-log(Membership);           
            end          
       end
    end


    lone_p=-0.07;
    [C,cost] = do_assignment (L_tot,-log(-lone_p), 1e9);
    

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

     % figure;
     % chain_nr=chain_nr+1;

     El=[]; c=0;
        for i=1:nchain+1
             ind=find(chain_nr==i);          
             L_S=0;
             for x=1:length(ind)-1
                 L_S=L_S+L_tot(ind(x),ind(x+1));
                 tmp(x)=L_tot(ind(x),ind(x+1));
             end
             if min(diff(locs(ind)))<ICI_min
                 El=[El ind'];
             end
             if median(ref_ToAs(ind))<3.3
                El=[El ind'];
             end
             if std(rmoutliers(ref_ToAs(ind)))>1.5
                El=[El ind'];
             end                     
             ICI_ind=diff(locs(ind));
             if length(ind)==3 & abs(log(ICI_ind(2)/ICI_ind(1)))>0.1
                El=[El ind'];
             end
             % if length(ind)==3 & mean(ICI_ind)<0.7
             %    El=[El ind'];
             % end
             if length(ind)<3 %& min(diff(locs(ind)))<1.5
                 El=[El ind'];
             elseif isscalar(ind)
                 El=[El ind'];
             else
                 c=c+1;
                 Detection_inds(c)={ind};
             end        
        end
        El=unique(El);
        All_traces=chain_nr; All_traces(El)=[];
        All_traces(find(All_traces==0))=[];
        Detected_traces=unique(All_traces)';
         Gr={};
         if ~isempty(Detected_traces)
            for i=Detected_traces
                    Gr(i)={find(chain_nr==i)};
            end                  
            Detected_subtrains= Gr(~cellfun(@isempty, Gr));
         else
             Detected_subtrains={};
         end


         
end