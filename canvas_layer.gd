extends CanvasLayer

@onready var countdown_label = %countdownLabel
@onready var time_label = %timeLabel
@onready var start_timer = %startTimer
@onready var clock_timer = %clockTimer
@onready var lap_label = %LapLabel

var count = 3
var total_msecs = 0
var current_lap = 0
var max_laps = 2
static var img = preload("res://assets/icons/lighting.png")

func _ready():
    add_to_group("ui")
    lap_label.text = "Lap: %d/%d" % [current_lap, max_laps]
    countdown_label.text = str(count)
    time_label.text = "00:00:00" 
    set_health(GameEvents.total_lives)
    GameEvents.life_lost.connect(_on_life_lost)
    start_timer.start()
    

func _on_life_lost(remaining_lives):
    set_health(remaining_lives)

func set_health(amount):
    var health_container = $MarginContainer/HBoxContainer
    for child in health_container.get_children():
        child.queue_free()
    for i in range(amount):
        var text_rect = TextureRect.new()
        text_rect.texture = img
        text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        text_rect.custom_minimum_size = Vector2(40, 40)
        text_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        health_container.add_child(text_rect)

func _on_start_timer_timeout():
    count -= 1
    if count > 0:
        countdown_label.text = str(count)
        start_timer.start()
    elif count == 0:
        countdown_label.text = "GO!"
        GameEvents.race_started.emit()
        clock_timer.start()  
        await get_tree().create_timer(1.0).timeout
        countdown_label.hide()

func _on_clock_timer_timeout():
    total_msecs += 1
    var msecs = total_msecs % 100
    var seconds = (total_msecs / 100) % 60
    var minutes = (total_msecs / 6000)   
    time_label.text = "%02d:%02d:%02d" % [minutes, seconds, msecs]

func stop_race():
    clock_timer.stop()
    countdown_label.show()

func finish_race():
    stop_race()
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.set_physics_process(false)
    get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func update_lap():
    if count <= 0:
        if current_lap < max_laps:
            current_lap += 1
            lap_label.text = "Lap: %d/%d" % [current_lap, max_laps]
        else:
            finish_race()
