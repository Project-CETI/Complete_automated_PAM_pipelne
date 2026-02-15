
function [theta, phi] = vector_to_angles(dir)
    theta = atan2d(dir(2), dir(1));
      % if theta < 0, theta = theta + 360; end
    phi = acosd(dir(3) / norm(dir));
end