function [start_time,record_time]=Extract_datetime(Audioname,t_test)
    % Extract YYYYMMDD
    date_str = regexp(Audioname, '\d{8}', 'match', 'once');
    
    % Extract hh, mm, ss
    time_parts = regexp(Audioname, '(\d{2})h(\d{2})mn(\d{2})', 'tokens', 'once');
    
    hour = str2double(time_parts{1});
    minute = str2double(time_parts{2});
    second = str2double(time_parts{3});
    
    % Build datetime
    record_time = datetime(date_str, 'InputFormat', 'yyyyMMdd') + ...
                  hours(hour) + minutes(minute) + seconds(second);
    start_time = record_time + seconds(t_test);
end
