function [Y, inds] = rmoutliers_custom(x,tr)
%RMOUTLIERS_CUSTOM Removes outliers from a 1xN vector using MAD method
%   [Y, inds] = rmoutliers_custom(x)
%   x    - input 1×N vector
%   tr   - Scalar representing MAD threshold
%   Y    - vector with outliers removed
%   inds - logical index of values in x that are outliers

% Convert to row vector if not already
x = x(:)';  

% Compute median and MAD
med_x = median(x);
mad_x = mad(x, 1);  % Median Absolute Deviation, normalized

% Outlier logic (similar to MATLAB): |x - median| > threshold * MAD
inds = abs(x - med_x) > tr * mad_x;

% Return filtered data
Y = x(~inds);

end