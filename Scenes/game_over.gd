extends Control
var level_scene:PackedScene=load("res://Scenes/game_over.tscn")
func _ready() -> void:
	$MarginContainer2/VBoxContainer/HBoxContainer/ScoreUpdater.text=$MarginContainer2/VBoxContainer/HBoxContainer/ScoreUpdater.text+str(Glogal.score)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		get_tree().change_scene_to_packed(level_scene)
	
