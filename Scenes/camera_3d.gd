extends Camera3D

@onready var car = get_parent()

var default_position: Vector3
var default_rotation: Vector3

@export var side_offset = 20.0
@export var side_speed = 4.0

@export var speed_pullback = 2.0    
@export var speed_pull_speed = 3.0 

@export var steer_lean = 3.0 
@export var lean_speed = 2.0

func _ready():
	default_position = position
	default_rotation = rotation_degrees

func _physics_process(delta):
	var steer = Input.get_axis("steer_right", "steer_left")
	var speed = car.linear_velocity.length()

	var target_x = default_position.x + (-steer * side_offset)
	position.x = lerp(position.x, target_x, delta * side_speed)
