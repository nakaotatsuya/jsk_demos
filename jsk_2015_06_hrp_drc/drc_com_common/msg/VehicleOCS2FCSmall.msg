# message for vehicle task from OCS to FC
bool execute_flag

# from operation interface 
float32 handle_cmd # drive/operation/handle_cmd
float32 accel_cmd # drive/operation/handle_cmd
float32 brake_cmd # drive/operation/brake_cmd
float32 neck_y_cmd # drive/operation/neck_cmd
float32 neck_p_cmd # drive/operation/neck_cmd

# from vehicle_ui
bool initialize_request
bool grasp_request
bool release_request
bool correct_request
bool resume_request
bool approach_handle_request
bool approach_accel_request
bool reach_arm_request
bool reach_leg_request
bool egress_request
bool set_max_step_request
float32 set_max_step_request_value
bool set_min_step_request
float32 set_min_step_request_value
bool set_detach_step_request
float32 set_detach_step_request_value
bool overwrite_handle_angle_request
float32 overwrite_handle_angle_request_value
bool set_real_request
uint8 set_real_request_value

bool set_handle_mode_request
uint8 set_handle_mode_request_value
bool set_accel_mode_request
uint8 set_accel_mode_request_value
bool set_neck_mode_request
uint8 set_neck_mode_request_value
