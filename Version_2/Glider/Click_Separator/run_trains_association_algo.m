function Whale=run_trains_association_algo(trajectories,id_clicks,Sig,Fs,P,Plot_flag)  

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
%   > id_clicks        - Sturct containing the attributes of click trains
%   > P.lone_p         - Scalar: Lone penalty over unassigned click trains      
%   > P.ITI_min        - Scalar: minimum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
%   > P.ITI_max        - Scalar: maximum allowed time gap (Inter-train interval (ITI)) between click trains [sec]
%   > P.roi            - Scalar: region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
%   > Sig              - Vector reprsenting a band-passed signal
%   > Fs               - Scalar: smpale rate of the signal 

%   OUTPUT:
%   > Whale              - struct containing the arrival times, amplitudes and slant delays of all clicks of each identified source whale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    Whale(1).ToAs=[];
    Whale(1).Elevation=[];
    Whale(1).Bearing=[];
    Whale(1).Amps=[];
    Whale(1).Rank=[];

    trajectories = trajectories(~cellfun(@isempty, trajectories));
    Nd=length(trajectories);
    if Nd>0
        L_tot = 1e9*ones(Nd,Nd);
        for i=1:Nd-1
            locs_i=cell2mat(id_clicks.ToAs(trajectories{i})');
            t_i_last=locs_i(end);  
            Bearing_i=cell2mat(id_clicks.Bearing(trajectories{i})');
            Elevation_i=cell2mat(id_clicks.Elevation(trajectories{i})');
            mu_i=mean([Bearing_i Elevation_i]);
            Sigma_i=eye(2).*std([Bearing_i Elevation_i]);
            for j=i+1:Nd  
                locs_j=cell2mat(id_clicks.ToAs(trajectories{j})');
                t_j_first=locs_j(1);
                Bearing_j=cell2mat(id_clicks.Bearing(trajectories{j})');
                Elevation_j=cell2mat(id_clicks.Elevation(trajectories{j})');
                mu_j=mean([Bearing_j Elevation_j]);
                Sigma_j=eye(2).*std([Bearing_j Elevation_j]);
    
                if t_j_first-t_i_last>P.ITI_min && t_j_first-t_i_last<P.ITI_max                          
                     L_tot(i,j)=bhattacharyya_gaussian(mu_i', Sigma_i, mu_j', Sigma_j);                                       
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
    
        individual_trains_idx=find(chain_nr==0);
        Max_idx=max(chain_nr);
        for ii=1:length(individual_trains_idx)
          L_train=length(cell2mat(id_clicks.ToAs(cell2mat(trajectories(individual_trains_idx(ii))))'));
          if L_train>P.min_numer_of_clicks_per_whale
              Max_idx=Max_idx+1;
              chain_nr(individual_trains_idx(ii))=Max_idx;
          end
        end
     
         Det={};
         c=0;
         for i=1:max(chain_nr)
             ind=find(chain_nr==i); 
             if ~isempty(ind)
                 c=c+1;
                 Det(c)={ind};
             end
         end
         

        cc=1;
        if Plot_flag.Click_separation
            subplot(2,2,1); hold off;
            t_Sig=(0:1/Fs: (1/Fs)*(length(Sig)-1))';
            plot(t_Sig,Sig);  hold on; grid on;
            subplot(2,2,3); hold off; 
            plot(0,0,'.'); hold on; grid on;          
            co={'r*','g*','c*','m*','k*','y*','r+','g+','c+','m+','k+','y+','ro','go','co','mo','ko','yo'};
            cc=1;
            legendInfo{cc} = '';
         end
         for i=1:length(Det)
            whale1=Det{i}';
            sol=cell2mat(id_clicks.ToAs(cell2mat(trajectories(whale1)))')';
            if length(sol)>P.min_numer_of_clicks_per_whale
                cc=cc+1;
                Bearing_angle=cell2mat(id_clicks.Bearing(cell2mat(trajectories(whale1)))'); 
                Elevation_angle=cell2mat(id_clicks.Elevation(cell2mat(trajectories(whale1)))');
                Pks=cell2mat(id_clicks.Amps(cell2mat(trajectories(whale1)))')'; 
                Whale(cc-1).ToAs=sol;
                Whale(cc-1).Elevation=Elevation_angle;
                Whale(cc-1).Bearing=Bearing_angle;
                Whale(cc-1).Amps=Pks;
                if Plot_flag.Click_separation
                    subplot(2,2,3); 
                    dotH=plot(sol,Bearing_angle,co{cc-1},'LineWidth',2);  hold on;
                    pause(0.005);
                    set(dotH, 'XData', sol, 'YData', Bearing_angle); hold on;       
                    legendInfo{cc} = ['Whale ' num2str(cc-1)];
                    % legend(legendInfo)
                    subplot(2,2,1); hold on;
                    dotH3=plot(sol',Pks,co{cc-1},'LineWidth',2);  hold on;
                    pause(0.005);
                    set(dotH3, 'XData', sol, 'YData', Pks); hold on;
                    % legend(legendInfo)
                end
            end
            % pause;        
        end
         if Plot_flag.Click_separation
            xlabel('Time [sec]'); ylabel('Bearing [\circ]'); title('Separation results');
            % legend(legendInfo)
         end
    else
        if Plot_flag.Click_separation
            subplot(2,2,3); hold off; 
            sol=cell2mat(id_clicks.ToAs(trajectories{1})')';
            Bearing_angle=cell2mat(id_clicks.Bearing(cell2mat(trajectories(1)))'); 
            dotH=plot(sol,Bearing_angle,'*','LineWidth',2);  hold on; grid on;
            pause(0.005);
            set(dotH, 'XData', sol, 'YData', Bearing_angle); hold on; grid on;
        end
    end

    
    if Plot_flag.Click_separation
        subplot(2,2,3);
        xlabel('Time [sec]');
        ylabel('Bearing [\circ]');
        title('Click train source assignment');  
        subplot(2,2,1);
        xlabel('Time [sec]');
        ylabel('Amplitude');
        title('Separation results');
    end
  
       for whale_index=1:length(Whale)
            Power=Whale(whale_index).Amps;
            Whale(whale_index).Rank=mean(Power)*length(Power);
       end
end