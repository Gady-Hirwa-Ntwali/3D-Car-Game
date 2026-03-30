extends RigidBody3D

@export var max_engine_force  = 280.0
@export var max_steering      = 0.8
@export var traction_factor   = 4.0
@export var top_speed         = 120.0

# === ENGINE SOUND VARIABLES ===

@export var min_pitch: float = 0.85
@export var max_pitch: float = 42.8
@export var pitch_ramp_up_speed: float = 10.0      # How fast sound rises when accelerating
@export var pitch_ramp_down_speed: float = 4.8    # How fast sound falls when coasting
@export var volume_ramp_speed: float = 8.0

var target_pitch: float = 1.0
var current_throttle: float = 0.0


var current_steering = 0.0
var wheel_spin        = 0.0
var is_interior_view  = false
var can_input_work = false
var recoveryMode = false
var current_pitch: float = 0.5

@onready var wheel_fl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_000
@onready var wheel_fr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_001
@onready var wheel_rl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_002
@onready var wheel_rr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_003
@onready var exterior_cam = $Camera3D
@onready var interior_cam = $InternalCamera
@onready var speed_label  = $"../CanvasLayer/Label"
@onready var car_mesh     = $Sketchfab_Scene
@onready var engine_sound: AudioStreamPlayer3D =$AccelSound

func _ready() -> void:
	exterior_cam.current = true
	interior_cam.current = false
	await get_tree().create_timer(4.0).timeout
	can_input_work = true
	
	
	
	
	
func _input(_event):
	if can_input_work and Input.is_action_just_pressed("toggle_camera"):
		is_interior_view = !is_interior_view
		exterior_cam.current = !is_interior_view
		interior_cam.current = is_interior_view
		
func _physics_process(delta: float) -> void:
	
	if recoveryMode:
		var behind_position = global_position - (linear_velocity * 0.03)
		global_position = global_position.move_toward(behind_position, top_speed)
		linear_velocity = linear_velocity.move_toward(Vector3.ZERO, top_speed * delta)
		return
	update_engine_sound(delta)
	var movef_R = Input.get_axis("move_backward", "move_forward")
	var steer    = Input.get_axis("steer_right", "steer_left")
	var speed    = linear_velocity.length()
	var speed_ratio    = clamp(top_speed/speed, 0.0, 1.0)
	var steering_limit = lerp(max_steering, max_steering * 0.8 , speed_ratio)
	current_steering   = lerp(current_steering, steer * steering_limit, delta * 7.0)
	
	if speed > 0.5:
		var steer_speed = lerp(3.0, 1.5, speed_ratio)
		rotate_y(current_steering * steer_speed * delta)
		
	if can_input_work and speed < top_speed or movef_R < 0:
		var forward = -global_transform.basis.z * movef_R
		apply_central_force(forward * max_engine_force * mass)
		
		if abs(movef_R) < 0.1:
			var forward_dir = -global_transform.basis.z
			var forward_speed = linear_velocity.dot(forward_dir)
			linear_velocity -= forward_dir * forward_speed * 2.5 * delta
		
	var local_vel   = global_transform.basis.inverse() * linear_velocity
	local_vel.x    *= pow(1.0 - clamp(traction_factor * delta, 0.0, 1.0), 1.0)
	linear_velocity = global_transform.basis * local_vel
	
	var lateral_slip = local_vel.x / max(speed, 0.1)
	var target_tilt  = lateral_slip * 30.0
	car_mesh.rotation_degrees.z= lerp(car_mesh.rotation_degrees.z, target_tilt, delta * 5.0)
	
	if speed > 0.5:
		wheel_spin += -sign(movef_R) * speed * delta * 180.0
	var ws = deg_to_rad(wheel_spin)
	wheel_fl.rotation = Vector3(ws, current_steering, 0)
	wheel_fr.rotation = Vector3(ws, current_steering, 0)
	wheel_rl.rotation = Vector3(ws, 0, 0)
	wheel_rr.rotation = Vector3(ws, 0, 0)
	


func _on_area_3d_collision() -> void:
	recoveryMode = true
	$ColisionSound.play()
	await get_tree().create_timer(1).timeout	
	recoveryMode = false
	
func update_engine_sound(delta: float) -> void:
	if not engine_sound:
		return
	var movef_R = Input.get_axis("move_backward", "move_forward")
	current_throttle = abs(movef_R)
	var speed = linear_velocity.length()
	var speed_factor = clamp(speed / top_speed, 0.0, 1.0)
	target_pitch = lerp(min_pitch, max_pitch, speed_factor * 0.65 + current_throttle * 0.55)
	var ramp_speed = pitch_ramp_up_speed if current_throttle > 0.05 else pitch_ramp_down_speed
	current_pitch = lerp(current_pitch, target_pitch, delta * ramp_speed)
	var target_volume = -1.0 + (current_throttle * 14.0)
	engine_sound.volume_db = lerp(engine_sound.volume_db, target_volume, delta * volume_ramp_speed)
	
	if current_throttle > 0.05:
		if not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound.playing:
			engine_sound.stop()
