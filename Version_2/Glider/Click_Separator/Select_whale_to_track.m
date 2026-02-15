function Follow_bearing=Select_whale_to_track(Sig,Fs,Separated_Clicks,Plot_flag)

     [max_rank,id_max_rank]=max([Separated_Clicks.Rank]);
     Chosen_whale=Separated_Clicks(id_max_rank);
     Follow_bearing=median(Chosen_whale.Bearing);

     if Plot_flag.Chosen_whale
         t=(0:1/Fs: (1/Fs)*(length(Sig)-1))';
         figure;
         plot(t,Sig); hold on; grid on;
         plot(Separated_Clicks(id_max_rank).ToAs,Separated_Clicks(id_max_rank).Amps,'*','LineWidth',2);
         title(['Bearing=' num2str(Follow_bearing) '\circ, Rank=' num2str(max_rank)])
     end

end