extends Node2D

const LEVEL_TIME_S = 180.0
var health = 3
var level_timer : Timer
var current_heat = 0.0
var heat_speed = 1

var game_running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 3
	SignalBus.minigame_failed.connect(_minigame_failed)
	SignalBus.minigame_succeeded.connect(_minigame_succeeded)
	
	%PotionLiquid.play("default")
	%Fire.play("default")
	
	level_timer = Timer.new()
	level_timer.one_shot = true
	level_timer.wait_time = LEVEL_TIME_S
	level_timer.timeout.connect(_finish_level)
	add_child(level_timer)
	level_timer.start()
	game_running = true

func _lose_potion_failure():
	game_running = false

func _lose_no_health():
	game_running = false

func _finish_level():
	game_running = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		current_heat += %HeatBar.step * heat_speed
		%HeatBar.value = current_heat
		if current_heat == %HeatBar.max_value:
			_lose_potion_failure()
			return
		elif current_heat >= (%HeatBar.max_value/3)*2:
			%Fire.play("high")
			%PotionLiquid.play("high")
		elif current_heat >= %HeatBar.max_value/3:
			%Fire.play("medium")
			%PotionLiquid.play("medium")
		else:
			%Fire.play("default")
			%PotionLiquid.play("default")

func _minigame_failed():
	%CurrentMinigame.get_child(0).queue_free()
	health -= 1
	if health == 0:
		_lose_no_health()
		return
	
	%Avatar.frame = health

func _minigame_succeeded():
	%CurrentMinigame.get_child(0).queue_free()

func _on_main_background_gui_input(event):
	pass


func _on_main_click_area_gui_input(event):
	if game_running:
		if event is InputEventMouseButton and event.pressed:
			SignalBus.hand_clicked.emit(event.button_index)
