function Click_detections=Extract_click_AoAs(Audio_name,S_t_HPF,Click_detections,P,Fs)
%   AUTHOR:         Guy Gubnitsky
%   DATE:           November 2025
%   DESCRIPTION:

%   This function gets a buffer from a raw audio file with the location 
%   of click detections and attributes them with the corresponding whale source
%   and estimates their angle of arrival with respect to global reference. 

%   INPUT:
%   > Audio_name               - String noting the Audio name
%   > Raw_audio                - Matrix of MX4 comprising 4 channels of M samples of a segment from a the audio file
%   > Click_Detections         - Struct containing the arrival times and amplitudes of detected clicks 
%   > Fs                       - Scalar representing the sampling frequency.
%   > P                        - Struct containing the detector parameters
%   > Plot_flag                - Flag for visualizing results

%   OUTPUT:
%   > Whale_output  - Struct containing the whales and glider parameters at each click arriaval time: 

%   > Whale_output.click_arrival_times_datetime
%   > Whale_output.click_arrival_times_sec
%   > Whale_output.click_amplitudes
%   > Whale_output.glider_latitude
%   > Whale_output.glider_longitude
%   > Whale_output.glider_heading
%   > Whale_output.whale_bearing_from_glider
%   > Whale_output.Glider_depth
%   > Whale_output.Rank (clicks average amplitide X number of clicks)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Click_detections.whale_bearing=zeros(1,length(Click_detections.ToAs));
    Click_detections.whale_elevation=zeros(1,length(Click_detections.ToAs));
    Click_detections.ROIs=cell(1,length(Click_detections.ToAs)); 

%% Prepare audio data for analysis
    test_multi=S_t_HPF(:,P.Channels_idx);
    t_test=(0:1/Fs: (1/Fs)*(length(test_multi)-1))';
    [start_time,~]=Extract_datetime(Audio_name,t_test);   
    Locs_datetime=start_time(int32((Click_detections.ToAs)'*Fs));
    Orientation=Extract_glider_orientation(P.AllData,Locs_datetime);

    for click_idx=1:length(Click_detections.ToAs)
        if  (Click_detections.ToAs(click_idx)+P.roi)*Fs<length(t_test)
            ROI=test_multi(int32((Click_detections.ToAs(click_idx)-P.roi)*Fs):int32((Click_detections.ToAs(click_idx)+P.roi)*Fs),:)';          
            Glider_sensor_data.heading=Orientation.heading_at_clicks(click_idx);
            Glider_sensor_data.pitch=Orientation.pitch_at_clicks(click_idx);
            Glider_sensor_data.roll=Orientation.roll_at_clicks(click_idx);
            Glider_sensor_data.declination=Orientation.declination_at_clicks(click_idx);
           
           [bearing_world_frame, elevation_world_frame,~, ~]=Estimate_angles(P.sensor_pos,Glider_sensor_data,ROI,Fs);

           Click_detections.whale_bearing(click_idx)=bearing_world_frame;
           Click_detections.whale_elevation(click_idx)=elevation_world_frame;
           Click_detections.ROIs(click_idx)={ROI(1,:)'};             
        end 
    end
    
end