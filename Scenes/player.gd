extends RigidBody3D

# ── Tunable parameters ──────────────────────────────────────────
@export var max_engine_force  = 280.0    
@export var max_steering      = 0.8
@export var traction_factor   = 4.0      
@export var brake_force       = 8.0    
@export var top_speed         = 120.0    
@export var track_group_name: String = "track"

var current_steering = 0.0
var wheel_spin        = 0.0
var is_interior_view  = false
var can_move = false # New variable to track race state

@onready var wheel_fl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_000
@onready var wheel_fr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_001
@onready var wheel_rl     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_002
@onready var wheel_rr     = $Sketchfab_Scene/Sketchfab_model/"176a2ec9ad5b42f386cc8a095b1e1f70_fbx"/RootNode/WheelFront_003
@onready var exterior_cam = $Camera3D
@onready var interior_cam = $InternalCamera

func _ready() -> void:
    add_to_group("player") # Ensures the Finish Line recognizes the car
    
    # Connect to the race signal
    GameEvents.race_started.connect(_on_race_started)
    
    global_transform.origin.y += 0.5 
    linear_damp  = 0.5
    angular_damp = 5.0
    gravity_scale = 4.0

    # Keep the car frozen until the countdown ends
    freeze = true
    can_move = false
    
    exterior_cam.current = true
    interior_cam.current = false

func _on_race_started():
    can_move = true
    freeze = false # Physically unlocks the car

func _input(event):
    if Input.is_action_just_pressed("toggle_camera"):
        is_interior_view = !is_interior_view
        exterior_cam.current = !is_interior_view
        interior_cam.current = is_interior_view

func _physics_process(delta: float) -> void:
    # If the race hasn't started, don't process movement or input
    if not can_move:
        return

    var throttle = Input.get_axis("move_backward", "move_forward")
    var steer    = Input.get_axis("steer_right", "steer_left")
    var speed    = linear_velocity.length()

    # ── Steering ────────────────────────────────────────────────────
    var speed_ratio    = clamp(speed / top_speed, 0.0, 1.0)
    var steering_limit = lerp(max_steering, max_steering * 0.8, speed_ratio)
    current_steering   = lerp(current_steering, steer * steering_limit, delta * 7.0)

    if speed > 0.5:
        var steer_speed = lerp(3.0, 1.5, speed_ratio)
        rotate_y(current_steering * steer_speed * delta)

    # ── Engine force (capped at top_speed) ──────────────────────────
    if speed < top_speed or throttle < 0:
        var forward = -global_transform.basis.z * throttle
        apply_central_force(forward * max_engine_force * mass)

    # ── Traction: kill lateral (sideways) velocity every frame ───────
    var local_vel   = global_transform.basis.inverse() * linear_velocity
    local_vel.x    *= pow(1.0 - clamp(traction_factor * delta, 0.0, 1.0), 1.0)
    linear_velocity = global_transform.basis * local_vel

    # ── Braking / natural drag when no throttle ──────────────────────
    if throttle == 0.0 and speed > 0.1:
        var drag = -linear_velocity.normalized() * min(brake_force, speed) * mass
        apply_central_force(drag)

    # ── Wheel visuals ────────────────────────────────────────────────
    if throttle != 0 and speed > 0.5:
        wheel_spin += -sign(throttle) * speed * delta * 180.0

    var ws = deg_to_rad(wheel_spin)
    wheel_fl.rotation = Vector3(ws, current_steering, 0)
    wheel_fr.rotation = Vector3(ws, current_steering, 0)
    wheel_rl.rotation = Vector3(ws, 0, 0)
    wheel_rr.rotation = Vector3(ws, 0, 0)
