function [bearing, elevation] = vector_to_bearing_elevation(dir)
    bearing = atan2d(dir(2), dir(1));
     % if bearing < 0, bearing = bearing + 360; end
    elevation = -asind(dir(3) / norm(dir));
end