
function [bearing_correct, elevation_correct,theta_body_est, phi_body_est]=Estimate_angles(sensor_pos_body,Glider_sensor_data,ROI,Fs)


%% Glider Attitude and Location
% Glider measurements (from onboard sensors)
heading_magnetic = Glider_sensor_data.heading;   % degrees (from magnetic north - what compass reads)
pitch = Glider_sensor_data.pitch;              % degrees (nose down)
roll = Glider_sensor_data.roll;               % degrees (right wing down)

% Magnetic declination at glider location (from World Magnetic Model)
% Convention: 
%   Positive = magnetic north is EAST of true north
%   Negative = magnetic north is WEST of true north
declination = Glider_sensor_data.declination;       % degrees (e.g., Boston, MA area)

% Correct heading to true north
heading_true = heading_magnetic + declination;


%% Step 1: Estimate AoA in Body Frame

Q = 4;
delays = zeros(Q-1, 1);
for q = 2:Q
    [xcorr_vals, lags] = xcorr(ROI(1,:), ROI(q,:));
    [~, max_idx] = max(abs(xcorr_vals));
    delays(q-1) = -lags(max_idx) / Fs;
end

R_m = sensor_pos_body(2:4,:) - sensor_pos_body(1,:);
k_body_estimated =(R_m \ delays);

k_body_estimated = k_body_estimated / norm(k_body_estimated);
[theta_body_est, phi_body_est] = vector_to_angles(k_body_estimated);

%% Step 2: Transform to World Frame (WITH declination correction)

% CORRECT: Using true heading (magnetic + declination)
dir_world_correct = body_to_world_frame(k_body_estimated, heading_true, pitch, roll);
[bearing_correct, elevation_correct] = vector_to_bearing_elevation(dir_world_correct);


end










