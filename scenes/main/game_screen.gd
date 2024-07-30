extends Node2D

const LEVEL_TIME_S = 120.0
var level_timer : Timer
var heat_speed = 20.0
var current_level_progress

var game_running = false

var minigame_events = []

var transform_sounds = [
	%TransformSFX1, %TransformSFX2, %TransformSFX3
]

const minigames = [
	preload("res://scenes/minigames/dialogue.tscn"),
	preload("res://scenes/minigames/eye_contact.tscn"),
	preload("res://scenes/minigames/hand_fidget.tscn"),
	preload("res://scenes/minigames/intrusive_thoughts.tscn")
]
var last_generated_minigame: int = -1
var next_minigame_timer: Timer

var love_interest_animation_timer: Timer

func _schedule_minigame():
	next_minigame_timer.wait_time = randi_range(GameState.event_delay_ranges[GameState.level][0], GameState.event_delay_ranges[GameState.level][1])
	next_minigame_timer.start()

func _spawn_minigame():
	var minigame_i = randi_range(0, minigames.size() - 1)
	while minigame_i == last_generated_minigame or minigame_i == -1:
		minigame_i = randi_range(0, minigames.size() - 1)
	var minigame = minigames[minigame_i].instantiate()
	last_generated_minigame = minigame_i
	if minigame_i == 3:
		%CurrentIntrusiveThoughts.add_child(minigame)
	else:
		%CurrentMinigame.add_child(minigame)

func _handle_love_interest_animation():
	var animation_choice = "wine" if randi_range(0, 3) == 0 else "default"
	%LoveInterest.play(animation_choice)
	%LoveInterest.animation_finished.connect(func(): love_interest_animation_timer.start())

func _on_dialogue_start():
	love_interest_animation_timer.stop()
	%LoveInterest.play("talk2")

func _on_dialogue_end():
	%LoveInterest.pause()
	%LoveInterest.frame = 1
	love_interest_animation_timer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.dialogue_started.connect(_on_dialogue_start)
	SignalBus.dialogue_ended.connect(_on_dialogue_end)
	
	heat_speed = GameState.heat_speeds[GameState.level]
	next_minigame_timer = Timer.new()
	next_minigame_timer.wait_time = randi_range(7, 12)
	next_minigame_timer.one_shot = true
	next_minigame_timer.timeout.connect(_spawn_minigame)
	add_child(next_minigame_timer)
	next_minigame_timer.start()
	
	love_interest_animation_timer = Timer.new()
	love_interest_animation_timer.wait_time = 4.0
	love_interest_animation_timer.one_shot = true
	love_interest_animation_timer.timeout.connect(_handle_love_interest_animation)
	add_child(love_interest_animation_timer)
	love_interest_animation_timer.start()
	
	GameState.health = 3
	SignalBus.minigame_failed.connect(_minigame_failed)
	SignalBus.minigame_succeeded.connect(_minigame_succeeded)
	
	%PotionLiquid.play("default")
	%Fire.play("default")
	
	for i in range(GameState.level):
		var progress = %Timers.get_child(i)
		progress.value = progress.max_value
	
	current_level_progress = %Timers.get_child(GameState.level)
	
	level_timer = Timer.new()
	level_timer.one_shot = true
	level_timer.wait_time = LEVEL_TIME_S
	level_timer.timeout.connect(_finish_level)
	add_child(level_timer)
	level_timer.start()
	game_running = true

func _lose():
	game_running = false
	%Match3.running = false
	if %CurrentMinigame.get_child_count() > 0:
		%CurrentMinigame.get_child(0).queue_free()
	var tween = create_tween()
	tween.tween_property(%fadeout, "self_modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if %TransformSFX3.playing:
			await %TransformSFX3.finished
		else:
			await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/main/lose_screen.tscn"))

func _finish_level():
	next_minigame_timer.stop()
	game_running = false
	%Match3.running = false
	if %CurrentMinigame.get_child_count() > 0:
		%CurrentMinigame.get_child(0).queue_free()
	var tween = create_tween()
	tween.tween_property(%fadeout, "self_modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var transition_to_next_screen = func():
		await get_tree().create_timer(2.0).timeout
		if GameState.level == 4:
			get_tree().change_scene_to_file("res://scenes/main/win_screen.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/main/bathroom_scene.tscn")
	tween.tween_callback(transition_to_next_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		var fraction_time_elapsed = (LEVEL_TIME_S - level_timer.time_left)/LEVEL_TIME_S
		current_level_progress.value = fraction_time_elapsed * current_level_progress.max_value
		
		%HeatBar.value += %HeatBar.step * heat_speed
		if %HeatBar.value >= %HeatBar.max_value:
			%PotionBreakSFX.play()
			_lose()
			return
		elif %HeatBar.value >= (%HeatBar.max_value/3)*2:
			%Fire.play("high")
			%PotionLiquid.play("high")
		elif %HeatBar.value >= %HeatBar.max_value/3:
			%Fire.play("medium")
			%PotionLiquid.play("medium")
		else:
			%Fire.play("default")
			%PotionLiquid.play("default")

func _animate_minigame_result(result: String):
	%MinigameResult.text = result
	%MinigameResult.visible = true
	var tween_in = create_tween()
	tween_in.tween_property(%MinigameResult, "scale", Vector2(1.0, 1.0), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween_in.finished
	var tween_out = create_tween()
	tween_out.tween_property(%MinigameResult, "scale", Vector2(0.0, 0.0), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween_out.tween_callback(func(): %MinigameResult.visible = false)

func _minigame_failed():
	%FailureSFX.play()
	await %FailureSFX.finished
	
	if last_generated_minigame == 3:
		%CurrentIntrusiveThoughts.get_child(0).queue_free()
	else:
		%CurrentMinigame.get_child(0).queue_free()
	_animate_minigame_result("Oops...")
	
	love_interest_animation_timer.stop()
	%LoveInterest.play("minigame_failure")
	%LoveInterest.animation_finished.connect(func(): love_interest_animation_timer.start())
	
	GameState.health -= 1
	%Avatar.frame = GameState.health
	%AvatarFlash.play("flash")
	
	if GameState.health == 2:
		%TransformSFX1.play()
	elif GameState.health == 1:
		%TransformSFX2.play()
	elif GameState.health == 0:
		%TransformSFX3.play()
		_lose()
		return
	
	_schedule_minigame()

func _minigame_succeeded():
	%SuccessSFX.play()
	await %SuccessSFX.finished
	
	if last_generated_minigame == 3:
		%CurrentIntrusiveThoughts.get_child(0).queue_free()
	else:
		%CurrentMinigame.get_child(0).queue_free()
	_animate_minigame_result("Nice!")
	
	love_interest_animation_timer.stop()
	%LoveInterest.play("minigame_success")
	%LoveInterest.animation_finished.connect(func(): love_interest_animation_timer.start())
	
	_schedule_minigame()

func _on_main_background_gui_input(event):
	pass

func _on_main_click_area_gui_input(event):
	if game_running:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			print("PLEASE FUCKING WORK")
			SignalBus.eye_contact_movement.emit(event)
		if event is InputEventMouseMotion or InputEventMouseButton:
			SignalBus.dialogue_movement.emit(event)
		if event is InputEventMouseButton and event.pressed:
			SignalBus.hand_clicked.emit(event.button_index)

func _on_main_click_area_mouse_exited():
	SignalBus.mouse_left_main_area.emit()
