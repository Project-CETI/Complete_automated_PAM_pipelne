function [trajectories,id_clicks]=run_train(Detections,P,Plot_flag)

%   AUTHOR:         Guy Gubnitsky
%   DATE:           February 2025
%   DESCRIPTION:

% This function combines assigned clicks from consecutive time buffers into complete click trains. 
% This is performed by tracking the click subsets via a MAP approach
% The function outputs structs containing the formed click trains and their
% clicks' arrival times.

%   INPUT:
%   > Detections         - Sturct containing the clicks' attributes of each source in each buffer
%   > P.roi              - Scalar: region of interest (roi)- defines the time window [in sec] around clicks for analyzing their surface echo
%   > P.Buffer_Params     - struct containing the GMM parameters of the clicks' similarity attributes in the buffer level
%   > Sig                - Vector reprsenting a band-passed signal
%   > Fs                 - Scalar: smpale rate of the signal

%   OUTPUT:
%   > trajectories    - Cell array containing the indices of the formed click trains
%   > id_j_ToAs       - Cell array containing the clicks' arrival times within the formed trains

% These two outputs are structured such that
% sol=cell2mat(id_j_ToAs(trajectories{j})'); is a vector containing the
% arrival times of all clicks in train with index j
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    id_j_ToAs={};
    id_j_Bearing={};
    id_j_Elevation={};
    id_j_Amps={};  
    trajectories={};

 
%%
    l_prev=0;
    transition_arcs=[];
    detection_arcs=[];
    co_1=0;
    co_2=0;
    for i=1:length(Detections)    
        if i==1
            C_i_en=0;
        else
            Pen=length(Detections(i).ICI)/(length(Detections(i).ICI)+length(Detections(i-1).ICI));
            if Pen==0
                Pen=eps;
            end
            C_i_en=-log(Pen);
        end
        if i<length(Detections)
            Pex=length(Detections(i).ICI)/(length(Detections(i).ICI)+length(Detections(i+1).ICI));
            if Pex==0
                Pex=eps;
            end        
           C_i_ex=-log(Pex);
        else
           C_i_ex=0;
        end
    

        C_i=log(0.01/0.99);
    
        for j=1:length(Detections(i).ICI)
            id_j=l_prev+j;       
            co_1=co_1+1;
            id_j_ToAs(co_1)=Detections(i).ToAs(j);
            id_j_Amps(co_1)=Detections(i).Amps(j);
            id_j_Bearing(co_1)=Detections(i).whale_bearing(j);
            id_j_Elevation(co_1)=Detections(i).whale_elevation(j);
            detection_arcs(co_1,:)=[id_j C_i_en C_i_ex C_i];
            Pkk_current=median(Detections(i).Pkk{j});

            Bearing_current=median(Detections(i).whale_bearing{j});
            Elevation_current=median(Detections(i).whale_elevation{j});
            DoA_current=[Bearing_current Elevation_current];
            ICI_current=median(Detections(i).ICI{j});
    
            for k=1:length(Detections(i+1).ICI)
                id_k=l_prev+length(Detections(i).ICI)+k;
                Pkk_next=median(Detections(i+1).Pkk{k});
                Bearing_next=median(Detections(i+1).whale_bearing{k});
                Elevation_next=median(Detections(i+1).whale_elevation{k});               
                DoA_next=[Bearing_next Elevation_next]; 
                ICI_next=median(Detections(i+1).ICI{k});

                ToA_prev=sort(Detections(i).ToAs{j});
                ToA_follow=sort(Detections(i+1).ToAs{k});
                if isempty(ToA_prev) | isempty(ToA_follow)
                    ICI_constraint=true;
                else
                    ICI_constraint=ToA_follow(1)-ToA_prev(end)>2;
                end
                alpha_Pkk=log(Pkk_next/Pkk_current);

                alpha_DoA= pdist([DoA_current ; DoA_next]);

                if abs(alpha_DoA)>P.max_AoA_change
                    DOA_constraint=1;
                else
                    DOA_constraint=0;
                end

                alpha_ICI=log(ICI_next/ICI_current);
                
                Features=[alpha_ICI alpha_Pkk alpha_DoA];
                L(j,k)=-log(Buffer_pairing_likelihood_glider(Features,P));
                if ICI_constraint || DOA_constraint
                    L(j,k)=-log(eps);
                end
    
                co_2=co_2+1;
                transition_arcs(co_2,:)=[id_j id_k L(j,k)];
                          
            end        
        end
        l_prev=l_prev+length(Detections(i).ICI);
    
    end
    
    if isempty(transition_arcs)
        c=0;
        for x=1:length(Detections)
            tmp=Detections(x).ToAs;
            if ~isempty(tmp)
            c=c+1;
            trajectories(c)={c};
            end
        end
        trajectories = trajectories';
    else    

        writematrix(detection_arcs,'detection_arcs.txt')
        writematrix(transition_arcs,'transition_arcs.txt')
    
    
        %% load affinity scores
        d_m = dlmread('detection_arcs.txt');
        t_m = dlmread('transition_arcs.txt');
        
        
        %% call mcc4mot

        [trajectories, ~] = mcc4mot(d_m,t_m);   

        %% Remove empty cells
        Remove_idx=[];
        for j=1:length(trajectories)
              if isempty(cell2mat(id_j_ToAs(trajectories{j})')')
                  Remove_idx=[Remove_idx j];
              end
        end
        trajectories(Remove_idx)=[];
        

    %%
        if Plot_flag.Click_separation
            subplot(2,2,4);  
            xlabel('Time [sec]'); ylabel('Bearing [\circ]'); 
            title('Click train formation');
            for j=1:length(trajectories)
                sol=cell2mat(id_j_ToAs(trajectories{j})')'; 
                Bearing=cell2mat(id_j_Bearing(trajectories{j})')';
                subplot(2,2,4);
                dotH=plot(sol,Bearing,'*','LineWidth',2);  hold on; grid on;
                pause(0.01);
                set(dotH, 'XData', sol, 'YData', Bearing); hold on; grid on;
                subplot(2,2,1); hold on;
                Pks=cell2mat(id_j_Amps(trajectories{j})')';    
                dotH3=plot(sol',Pks,'*','LineWidth',2);  hold on; grid on;
                pause(0.01);
                set(dotH3, 'XData', sol, 'YData', Pks); hold on; grid on;
            end
        end
       
    end

    if Plot_flag.Click_separation
        subplot(2,2,4);
        xlabel('Time [sec]');
        ylabel('Bearing [\circ]');
        title('Click train formation');
    
        subplot(2,2,1);
        xlabel('Time [sec]');
        ylabel('Voltage [V]');
    end

    id_clicks.ToAs=id_j_ToAs;
    id_clicks.Amps=id_j_Amps;
    id_clicks.Bearing=id_j_Bearing;
    id_clicks.Elevation=id_j_Elevation;
end