function Whale=run_trains_association_algo(trajectories,id_j_ToAs,Sig,Fs,P,Plot_flag)  

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2025
%   DESCRIPTION:

% This function assigns click trains into sources. This assignment involves 
% grouping trains of similar distributions in terms of the slant delay while
% taking into account possible silent periods between click trains due to 
% missed detections, foraging, or breathing cycles
% The function outputs a struct containing the arrival times and slant
% delays of all clicks of each identified sorce whale

%   INPUT:
%   > trajectories     - Sturct containing the indices of click trains
%   > id_j_ToAs        - Sturct containing the clicks' arrival times of click trains
%   > P.lone_p         - Scalar: Lone penalty over unassigned click trains      
%   > P.ITI_min        - Scalar: minimum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
%   > P.ITI_max        - Scalar: maximum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
%   > P.roi            - Scalar: region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
%   > Sig              - Vector reprsenting a band-passed signal
%   > Fs               - Scalar: smpale rate of the signal 

%   OUTPUT:
%   > Whale              - struct containing the arrival times, amplitudes and slant delays of all clicks of each identified source whale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cc=1;
    Whale(1).ToAs=[];
    Whale(1).Amps=[];
    Whale(1).Slant=[];
    Nd=length(trajectories);
    if Nd>1
        L_tot = 1e9*ones(Nd,Nd);
            for i=1:Nd-1
                locs_i=cell2mat(id_j_ToAs(trajectories{i})');
                t_i_last=locs_i(end);
                if length(locs_i)>P.n_clicks
                    sample_i=locs_i(end-P.n_clicks:end);
                else
                    sample_i=locs_i;
                end
                [ref_ToAs,~]=determine_reflection_ToAs(Sig,sample_i,0,P.roi,Fs,0);
                ref_i = rmoutliers(ref_ToAs);
                mu_i=mean(ref_i);
                sigma2_i=std(ref_i)^2;
               for j=i+1:Nd  
                    locs_j=cell2mat(id_j_ToAs(trajectories{j})');
                    t_j_first=locs_j(1);
                    if length(locs_j)>P.n_clicks
                        sample_j=locs_j(1:P.n_clicks);
                    else
                        sample_j=locs_j;
                    end    
                   [ref_ToAs,~]=determine_reflection_ToAs(Sig,sample_j,0,P.roi,Fs,0);
                   ref_j = rmoutliers(ref_ToAs);
                   mu_j=mean(ref_j);
                   sigma2_j=std(ref_j)^2;
                   if sigma2_i==0
                       sigma2_i=5e-3;
                   end
                   if sigma2_j==0
                       sigma2_j=5e-3;
                   end
        
                        if t_j_first-t_i_last>P.ITI_min && t_j_first-t_i_last<P.ITI_max                           
                             L_tot(i,j)=0.25*((mu_i-mu_j)^2/(sigma2_i+sigma2_j)+log(0.25*(sigma2_i/sigma2_j+sigma2_j/sigma2_i)+0.5));
                        
                        end  
    
               end
            end
        
            [C,~] = do_assignment (L_tot,P.lone_p, 1e9);
        
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
        
         Det={};
         c=0;
        for i=1:nchain+1
             ind=find(chain_nr==i);          
             L_S=0;
             for x=1:length(ind)-1
                 L_S=L_S+L_tot(ind(x),ind(x+1));
                 tmp(x)=L_tot(ind(x),ind(x+1));
             end
             c=c+1;
             Det(c)={ind};
        end
        Det = Det(~cellfun(@isempty, Det));

        for Det_idx=1:length(chain_nr)
            if ~chain_nr(Det_idx)
                Det=[Det {Det_idx}];
            end
        end


        Det_EL=[];
        if Plot_flag.Click_separation
            subplot(2,2,1); hold off;
            t_Sig=(0:1/Fs: (1/Fs)*(length(Sig)-1))';
            plot(t_Sig,Sig);  hold on; grid on;
            subplot(2,2,3); hold off; 
            plot(0,0,'.'); hold on; grid on;          
            co={'r*','g*','c*','m*','k*','y*','r+','g+','c+','m+','k+','y+'};
            cc=1;
            legendInfo{cc} = '';
         end
            for i=1:length(Det)
                whale1=Det{i}';
                    sol=cell2mat(id_j_ToAs(cell2mat(trajectories(whale1)))');
                    if length(sol)>P.rank_threshold
                        cc=cc+1;
                        [ref_ToAs,~]=determine_reflection_ToAs(Sig,sol,0,P.roi,Fs,0);
                        Slant=ref_ToAs; 
                        Whale(cc-1).ToAs=sol;
                        Whale(cc-1).Slant=ref_ToAs;
                        Pks=Peaks_extract(Sig,sol,Fs);
                        Whale(cc-1).Amps=Pks;
                        if Plot_flag.Click_separation
                            subplot(2,2,3); 
                            dotH=plot(sol,Slant,co{cc-1},'LineWidth',2);  hold on;
                            pause(0.005);
                            set(dotH, 'XData', sol, 'YData', Slant); hold on;       
                            legendInfo{cc} = ['Whale ' num2str(cc-1)];
                            legend(legendInfo)
                            subplot(2,2,1); hold on;
                            dotH3=plot(sol',Pks,co{cc-1},'LineWidth',2);  hold on;
                            pause(0.005);
                            set(dotH3, 'XData', sol, 'YData', Pks); hold on;
                            legend(legendInfo)
                        end
                    else
                        Det_EL=[Det_EL i];
                    end
                    % pause;        
            end
            if Plot_flag.Click_separation
                xlabel('Time [sec]'); ylabel('Slant delay [ms]'); title('Separation results');
                legend(legendInfo)
            end
        if ~isempty(Det_EL)
           Det(Det_EL)={[]};
        end
        Det = Det(~cellfun(@isempty, Det));
    else
        if Plot_flag.Click_separation
            subplot(2,2,3); hold off; 
            sol=cell2mat(id_j_ToAs(trajectories{1})')';
            [Slant,~]=determine_reflection_ToAs(Sig,sol,0,P.roi,Fs,0);
            dotH=plot(sol,Slant,'*','LineWidth',2);  hold on; grid on;
            pause(0.005);
            set(dotH, 'XData', sol, 'YData', Slant); hold on; grid on;
        end
        Det=trajectories;
    end

    
    if Plot_flag.Click_separation
        subplot(2,2,3);
        xlabel('Time [sec]');
        ylabel('Slant delay [ms]');
        title('Click train source assignment');  
        subplot(2,2,1);
        xlabel('Time [sec]');
        ylabel('Amplitude');
        title('Separation results');
    end
end