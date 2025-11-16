function Coda_flag=Coda_verify(Y,Y_1,F_ds,F_low,F_high,chanel_idx_verification,Coda_clicks_ToAs,range_max,depth_max)

      % Y_2=bandpass(Y(:,chanel_idx_verification),[F_low, F_high],F_ds); % Apply bandpass filter within the frequency range specified by the parameters F_low and F_high
      % Coda_clicks_ToAs_channel_2=associate_clicks(Y_1,Y_2,Coda_clicks_ToAs);
      % [range,depth]=localize_source(Coda_clicks_ToAs,Coda_clicks_ToAs_channel_2);
      % if range<range_max && depth<depth_max
      %     Coda_flag=1;
      % else
      %     Coda_flag=0;
      % end
      Coda_flag=1;
end