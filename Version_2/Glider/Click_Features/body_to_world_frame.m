function dir_world = body_to_world_frame(dir_body, heading, pitch, roll)
    R = rotation_matrix_body_to_world(heading, pitch, roll);
    dir_world = R * dir_body;
end