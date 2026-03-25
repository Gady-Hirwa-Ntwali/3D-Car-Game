extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.



func _on_finish_line_body_entered(body: Node3D) -> void:
    if body.is_in_group("player") :
        var ui = get_tree().get_first_node_in_group("ui")
        if ui:
            ui.update_lap()
