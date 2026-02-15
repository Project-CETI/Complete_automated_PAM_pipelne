function [xa, ya] = manualAlign(x, y)
    % Ensure signals are column vectors
    x = x(:); 
    y = y(:);

    % 1. Compute cross-correlation
    [corr, lags] = xcorr(x, y);

    % 2. Find the lag that maximizes the correlation
    [~, idx] = max(abs(corr));
    delay = lags(idx); % This is the estimated shift

    % 3. Align the signals based on the delay
    if delay > 0
        % x is ahead of y, so prepend zeros to x or shift y
        % To align them at the start:
        ya = [zeros(delay, 1); y];
        xa = x;
    elseif delay < 0
        % y is ahead of x
        xa = [zeros(abs(delay), 1); x];
        ya = y;
    else
        xa = x;
        ya = y;
    end

end