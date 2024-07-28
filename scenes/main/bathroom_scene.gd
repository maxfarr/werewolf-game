extends Node2D

func _refill_health():
	while GameState.health < 3:
		await get_tree().create_timer(0.7).timeout
		GameState.health += 1
		%Avatar.frame = GameState.health

# Called when the node enters the scene tree for the first time.
func _ready():
	%Avatar.frame = GameState.health
	%Player.frame = 0
	await get_tree().create_timer(1.0).timeout
	
	%DrinkSFX.play()
	%Player.frame = 1
	if GameState.health < 3:
		_refill_health()
	await %DrinkSFX.finished
	
	%Player.frame = 2
	await get_tree().create_timer(1.0).timeout
	GameState.level += 1
	
	var handle_input = func(event):
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				get_tree().change_scene_to_file("res://scenes/main/game_screen.tscn")
	
	%NextLevel.visible = true
	%MainContainer.gui_input.connect(handle_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
