extends Node3D
var finishLine1:= false
var finishLine2 := false
func _ready() -> void:
	Global.lap = 0
func _on_finish_line_body_entered(body: Node3D) -> void:
	if finishLine2:
		Global.lap +=1
		finishLine2 = false
	if Global.lap == 2:
		get_tree().change_scene_to_file("res://Scenes/Won.tscn")	

func _on_finish_line_2_body_entered(body: Node3D) -> void:
	finishLine2 = true

	
