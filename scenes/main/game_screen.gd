extends Node2D

const LEVEL_TIME_S = 180.0
var health = 3
var level_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 3
	SignalBus.minigame_failed.connect(_minigame_failed)
	SignalBus.minigame_succeeded.connect(_minigame_succeeded)
	
	level_timer = Timer.new()
	level_timer.one_shot = true
	level_timer.wait_time = LEVEL_TIME_S
	level_timer.timeout.connect(_finish_level)
	add_child(level_timer)
	level_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _lose_game():
	pass

func _finish_level():
	pass

func _minigame_failed():
	%CurrentMinigame.get_child(0).queue_free()
	health -= 1
	if health == 0:
		_lose_game()
		return
	
	%Avatar.frame = health

func _minigame_succeeded():
	%CurrentMinigame.get_child(0).queue_free()

func _on_main_background_gui_input(event):
	pass


func _on_main_click_area_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		SignalBus.hand_clicked.emit(event.button_index)
