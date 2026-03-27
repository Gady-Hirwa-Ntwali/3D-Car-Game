extends RigidBody3D

@export var max_engine_force  = 280.0
@export var max_steering      = 0.8
@export var traction_factor   = 4.0
@export var brake_force       = 8.0
@export var top_speed         = 120.0
@export var track_group_name: String = "track"

var current_steering = 0.0
var wheel_spin        = 0.0
var is_interior_view  = false
var can_input_work = false

@onready var wheel_fl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_000
@onready var wheel_fr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_001
@onready var wheel_rl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_002
@onready var wheel_rr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_003
@onready var exterior_cam = $Camera3D
@onready var interior_cam = $InternalCamera
@onready var speed_label  = $"../CanvasLayer/Label"

func _ready() -> void:
	exterior_cam.current = true
	interior_cam.current = false
	await get_tree().create_timer(4.0).timeout
	can_input_work = true

func _input(event):
	if can_input_work and Input.is_action_just_pressed("toggle_camera"):
		is_interior_view = !is_interior_view
		exterior_cam.current = !is_interior_view
		interior_cam.current = is_interior_view

func _check_wall_collisions():
	var space_state = get_world_3d().direct_space_state

	var directions = [
		Vector3(0, 0, -1),  # front
		Vector3(0, 0, 1),   # back
		Vector3(-1, 0, 0),  # left
		Vector3(1, 0, 0),   # right
	]

	for dir in directions:
		var from = global_position
		var to   = global_position + dir * 2.0

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self]

		var result = space_state.intersect_ray(query)
		if result:
			print("Hit wall: ", result.collider.name)

func _physics_process(delta: float) -> void:
	var throttle = Input.get_axis("move_backward", "move_forward")
	var steer    = Input.get_axis("steer_right", "steer_left")
	var speed    = linear_velocity.length()

	# Check wall collisions
	_check_wall_collisions()

	# 📊 SPEEDOMETER
	var speed_kmh = speed * 3.6
	#speed_label.text = "Speed: " + str(int(speed_kmh)) + " km/h"

	# ── Steering ─────────────────────────────────────────────────
	var speed_ratio    = clamp(speed / top_speed, 0.0, 1.0)
	var steering_limit = lerp(max_steering, max_steering * 0.8, speed_ratio)
	current_steering   = lerp(current_steering, steer * steering_limit, delta * 7.0)

	if speed > 0.5:
		var steer_speed = lerp(3.0, 1.5, speed_ratio)
		rotate_y(current_steering * steer_speed * delta)

	# ── Engine force ──────────────────────────────────────────────
	if can_input_work and speed < top_speed or throttle < 0:
		var forward = -global_transform.basis.z * throttle
		apply_central_force(forward * max_engine_force * mass)

	# ── Traction ──────────────────────────────────────────────────
	var local_vel   = global_transform.basis.inverse() * linear_velocity
	local_vel.x    *= pow(1.0 - clamp(traction_factor * delta, 0.0, 1.0), 1.0)
	linear_velocity = global_transform.basis * local_vel

	# ── Braking ───────────────────────────────────────────────────
	if can_input_work and  throttle == 0.0 and speed > 0.1:
		var drag = -linear_velocity.normalized() * min(brake_force, speed) * mass
		apply_central_force(drag)

	# ── Wheel visuals ─────────────────────────────────────────────
	if throttle != 0 and speed > 0.5:
		wheel_spin += -sign(throttle) * speed * delta * 180.0

	var ws = deg_to_rad(wheel_spin)
	wheel_fl.rotation = Vector3(ws, current_steering, 0)
	wheel_fr.rotation = Vector3(ws, current_steering, 0)
	wheel_rl.rotation = Vector3(ws, 0, 0)
	wheel_rr.rotation = Vector3(ws, 0, 0)
