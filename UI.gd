extends CanvasLayer

@onready var countdown_label = %countdownLabel
@onready var time_label = %timeLabel
@onready var start_timer = %startTimer
@onready var clock_timer = %clockTimer
@onready var laps = $laps

var count = 3
var total_msecs = 0
static var img = preload("res://assets/icons/lighting.png")

func _ready():
	countdown_label.text = str(count)
	time_label.text = "00:00:00"
	laps.text = "Laps: " +str(Global.lap) + "/2"
	start_timer.start()
	
func	 _process(delta: float) -> void:
		laps.text = "Laps: " +str(Global.lap) + "/2"
		
func set_life(life):
	for child in $MarginContainer/HBoxContainer.get_children():
		child.queue_free()
	for i in life:
		var text_rect = TextureRect.new()
		text_rect.texture = img
		$MarginContainer/HBoxContainer.add_child(text_rect)

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
	Global.time = time_label.text
	
func stop_race():
	clock_timer.stop()
	countdown_label.show()
