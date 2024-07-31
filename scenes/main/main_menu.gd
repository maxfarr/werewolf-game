extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_button_up():
	var tween = create_tween()
	tween.tween_property(%Fadein, "self_modulate:a", 1.0, 2.0)
	tween.tween_callback(func():
		await get_tree().create_timer(0.7).timeout
		get_tree().change_scene_to_file("res://scenes/main/game_screen.tscn"))
	
