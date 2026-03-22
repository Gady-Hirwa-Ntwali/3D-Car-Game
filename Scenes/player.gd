extends RigidBody3D

@export var max_engine_force = 1500.0
@export var max_steering = 0.4
var current_steering = 0.0
var wheel_spin = 0.0

@onready var wheel_fl = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_000
@onready var wheel_fr = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_001
@onready var wheel_rl = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_002
@onready var wheel_rr = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_003
@onready var car_body = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_011

func _physics_process(delta: float) -> void:
	var throttle = Input.get_axis("move_backward", "move_forward")
	var steer = Input.get_axis("steer_right", "steer_left")
	
	current_steering = lerp(current_steering, steer * max_steering, delta * 5.0)
	
	var speed = linear_velocity.length()
	
	# Step 1 - rotate car FIRST
	if speed > 0.5:
		rotate_y(current_steering * 4 * delta)
	
	# Step 2 - THEN get forward direction after rotation
	var forward = -global_transform.basis.z
	apply_central_force(forward * throttle * max_engine_force * delta)
	
	# Wheel spin
	var spin_speed = speed * delta * 3.0
	if throttle != 0 and speed > 0.5:
		if throttle > 0:
			wheel_spin -= spin_speed * 60
		else:
			wheel_spin += spin_speed * 60
	
	# Apply wheel rotations
	wheel_fl.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
	wheel_fr.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
	wheel_rl.rotation = Vector3(deg_to_rad(wheel_spin), 0, 0)
	wheel_rr.rotation = Vector3(deg_to_rad(wheel_spin), 0, 0)
