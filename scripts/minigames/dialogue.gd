extends Control

var seconds_to_start = 3
var text_timer: Timer
var countdown_timer: Timer
var game_running = false
var correct_option: int
signal text_done
signal countdown_done

func _display_number(number: int):
	%Countdown.text = str(number)
	%Countdown.scale = Vector2(1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(%Countdown, "scale", Vector2(0.0, 0.0), 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	%CountdownSFX.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.mouse_left_main_area.connect(_mouse_left_area)
	%Instructions.visible = false
	%Countdown.scale = Vector2(0.0, 0.0)
	var text = GameState.dialogue_options[randi_range(0, GameState.dialogue_options.size() - 1)]
	correct_option = randi_range(1, 2)
	if correct_option == 1:
		%Option1.text = text["correct"]
		%Option2.text = text["wolfy"]
	else:
		%Option1.text = text["wolfy"]
		%Option2.text = text["correct"]
	%Option1.visible = false
	%Option2.visible = false
	
	%Head.gravity_scale = 0.0
	var random_offset = 0
	while random_offset == 0:
		random_offset = randi_range(-3, 3)
	%Head.position.y += random_offset
	%Countdown.text = str(seconds_to_start)
	%LoveInterestText.text = text["loveinterest"]
	%LoveInterestText.visible_characters = 0
	var update_text = func():
		%LoveInterestText.visible_characters += 1
		
		if %LoveInterestText.visible_characters >= %LoveInterestText.text.length():
			text_timer.one_shot = true
			text_timer.stop()
			text_timer.queue_free()
			text_done.emit()
			SignalBus.dialogue_ended.emit()
		else:
			%DialogueTextSFX.play()
	
	text_timer = Timer.new()
	text_timer.wait_time = 0.06
	text_timer.one_shot = false
	text_timer.timeout.connect(update_text)
	add_child(text_timer)
	SignalBus.dialogue_started.emit()
	text_timer.start()
	await text_done
	await get_tree().create_timer(1.0).timeout
	%Instructions.visible = true
	%Animation.play("blink_instructions")
	%Option1.visible = true
	%Option2.visible = true
	
	var update_countdown = func():
		seconds_to_start -= 1
		if seconds_to_start == 0:
			%Countdown.queue_free()
			game_running = true
			%MinigameTimer.failure.connect(func():
				%Head.process_mode = Node.PROCESS_MODE_DISABLED
				SignalBus.minigame_failed.emit())
			%MinigameTimer._start(GameState.timer_durations_s["dialogue"][GameState.level])
			%Head.gravity_scale = 0.05
			%Head.apply_force(Vector2(randi_range(35,45), 0))
			%StartSFX.play()
			%Instructions.visible = false
			countdown_timer.one_shot = true
			countdown_timer.stop()
			countdown_done.emit()
			return
		else:
			_display_number(seconds_to_start)
	
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.timeout.connect(update_countdown)
	_display_number(seconds_to_start)
	add_child(countdown_timer)
	countdown_timer.start()
	await countdown_done
	
	SignalBus.dialogue_movement.connect(_handle_movement)

var mouse_left_down = false
var MOUSE_ACCEL = 7.5
var MOUSE_SENSITIVITY = 1.0
func _handle_movement(event):
	if game_running:
		if event is InputEventMouseMotion:
			if mouse_left_down:
				#var accel = MOUSE_ACCEL if event.velocity.y > 0 else (0 if event.velocity.y == 0.0 else -MOUSE_ACCEL)
				var accel = clamp(event.relative.y * MOUSE_SENSITIVITY, -12.0, 12.0)
				%Head.apply_force(Vector2(0, accel))
		elif event is InputEventMouseButton:
			if event.button_index == 1 and event.is_pressed():
				mouse_left_down = true
			elif event.button_index == 1 and not event.is_pressed():
				mouse_left_down = false

func _mouse_left_area():
	mouse_left_down = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_finish_area_body_entered(body):
	print(%Head.position.y)
	if (%Head.position.y > 26 and correct_option == 2) or (%Head.position.y <= 26 and correct_option == 1):
		%MinigameTimer._stop()
		%MinigameTimer.visible = false
		%Head.queue_free()
		game_running = false
		SignalBus.minigame_succeeded.emit()
	else:
		%Head.queue_free()
		game_running = false
		SignalBus.minigame_failed.emit()
