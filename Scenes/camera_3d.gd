extends Camera3D

@onready var car = get_parent()

var default_position: Vector3
var default_rotation: Vector3

var tilt_amount   = 8.0    # sideways slide amount (your original)
var tilt_speed    = 5.0    # how fast it slides (your original)

var drift_swing   = 4.5    # how far camera swings around the car (Y orbit)
var drift_speed   = 3.0    # how fast it swings into drift position
var drift_return  = 4.0    # how fast it returns to default when not drifting

# drift detection
var drift_threshold = 0.35  # how much sideways slip counts as a drift

func _ready():
	default_position = position
	default_rotation = rotation_degrees

func _physics_process(delta):
	var steer = Input.get_axis("steer_right", "steer_left")
	var speed = car.linear_velocity.length()

	# ── Detect drift by measuring sideways (lateral) slip ────────────
	var local_vel    = car.global_transform.basis.inverse() * car.linear_velocity
	var lateral_slip = local_vel.x / max(speed, 0.1)   # -1 to 1, how sideways the car is moving

	var is_drifting  = abs(lateral_slip) > drift_threshold and speed > 5.0

	# ── Sideways slide (your original tilt) ──────────────────────────
	var target_x = default_position.x + (-steer * tilt_amount)
	position.x   = lerp(position.x, target_x, delta * tilt_speed)

	# ── Drift swing: orbit camera around Y to show car broadside ─────
	var target_y_rot: float
	if is_drifting:
		# swing toward the direction the car is sliding
		# lateral_slip positive = sliding right = swing camera left to show right side
		target_y_rot = default_rotation.y + (-lateral_slip * drift_swing * 18.0)
	else:
		target_y_rot = default_rotation.y

	var swing_speed  = drift_speed if is_drifting else drift_return
	rotation_degrees.y = lerp(rotation_degrees.y, target_y_rot, delta * swing_speed)

	# ── Pull camera back slightly during drift so full side is visible─
	var target_z = default_position.z + (abs(lateral_slip) * 3.5 if is_drifting else 0.0)
	position.z   = lerp(position.z, target_z, delta * drift_speed)
