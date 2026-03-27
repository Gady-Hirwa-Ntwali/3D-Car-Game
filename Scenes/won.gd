extends Control
@export var time :Label

func _ready() -> void:
	time.text = Global.time

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Enter"):
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")
