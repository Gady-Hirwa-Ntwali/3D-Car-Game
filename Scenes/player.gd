extends VehicleBody3D

@export var max_engine_force = 3000.0
@export var max_brake_force = 10.0
@export var max_steering = 0.4

var current_steering = 0.0
var wheel_spin = 0.0
var is_interior_view = false

@onready var wheel_fl_mesh = $"wheel-front-left"
@onready var wheel_fr_mesh = $"wheel-front-right"
@onready var wheel_rl_mesh = $"wheel-front-right"
@onready var wheel_rr_mesh = $"wheel-back-left"

@onready var wheel_fl = $"wheel-front-left"
@onready var wheel_fr = $"wheel-front-right"
@onready var wheel_rl = $"wheel-back-left"
@onready var wheel_rr = $"wheel-back-right"

@onready var exterior_cam = $Camera3D
@onready var interior_cam = $InternalCamera

func _ready() -> void:
	exterior_cam.current = true
	interior_cam.current = false

func _input(_event):
	if Input.is_action_just_pressed("toggle_camera"):
		is_interior_view = !is_interior_view
		exterior_cam.current = !is_interior_view
		interior_cam.current = is_interior_view

func _physics_process(delta: float) -> void:
	var steer_input = Input.get_axis("steer_left", "steer_right")
	steering = lerp(steering, steer_input * 0.4, 5 * delta)
	var engine_input = Input.get_axis("move_forward", "move_backward")
	engine_force = engine_input * 300 
	
