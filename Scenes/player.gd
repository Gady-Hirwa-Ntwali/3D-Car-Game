extends RigidBody3D

@export var max_engine_force = 1500.0
@export var max_steering = 0.4
var current_steering = 0.0
var wheel_spin = 0.0
var is_interior_view = false

@onready var wheel_fl = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_000
@onready var wheel_fr = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_001
@onready var wheel_rl = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_002
@onready var wheel_rr = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_003
@onready var body = $"Sketchfab_Scene/Sketchfab_model/176a2ec9ad5b42f386cc8a095b1e1f70_fbx/RootNode/WheelFront_011"
@onready var exterior_cam = $Camera3D
@onready var interior_cam = $InternalCamera

func _ready() -> void:
    exterior_cam.current = true
    interior_cam.current = false
func _input(event):
    if Input.is_action_just_pressed("toggle_camera"):
        is_interior_view = !is_interior_view
        exterior_cam.current = !is_interior_view
        interior_cam.current = is_interior_view
func _physics_process(delta: float) -> void:
    var throttle = Input.get_axis("move_backward", "move_forward")
    var steer = Input.get_axis("steer_right", "steer_left")
    
    current_steering = lerp(current_steering, steer * max_steering, delta * 5.0)
    
    var speed = linear_velocity.length()
    if speed > 0.5:
        rotate_y(current_steering * 4 * delta)
    
    var forward = -global_transform.basis.z * throttle
    apply_central_force(forward * max_engine_force * delta)
    
    var spin_speed = speed * delta * 3.0

    if throttle != 0 and speed > 0.5:
        if throttle > 0:
            wheel_spin -= spin_speed * 60 
        else:
            wheel_spin += spin_speed * 60
    
    wheel_fl.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
    wheel_fr.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
    wheel_rl.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
    wheel_rr.rotation = Vector3(deg_to_rad(wheel_spin), current_steering, 0)
    #body.rotation = Vector3(deg_to_rad(270), current_steering*2, 0)
