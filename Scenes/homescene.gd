extends Control

var blink_timer = 0.0
var blink_speed = 0.5	# higher = faster blink
var visible_text = true

@onready var label = $Label

func _process(delta):
	# ── Blinking ──────────────────────────────────────────────────
	blink_timer += delta
	if blink_timer >= blink_speed:
		blink_timer = 0.0
		visible_text = !visible_text
		label.visible = visible_text

func _input(event):
	if Input.is_action_just_pressed("space"):
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")
