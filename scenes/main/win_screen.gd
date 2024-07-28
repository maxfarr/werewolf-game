extends Node2D

var progress = 0
var click_active = false

func _handle_click():
	click_active = false
	%Mouse.visible = false
	match progress:
		0:
			var tween = create_tween()
			tween.tween_property(%Panel1_2, "self_modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween.finished
		1:
			var tween1 = create_tween()
			tween1.tween_property(%Screen1, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween1.finished
			
			var tween2 = create_tween()
			tween2.tween_property(%Screen2, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween2.finished
		2:
			var tween = create_tween()
			tween.tween_property(%Panel2_2, "self_modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween.finished
		3:
			var tween = create_tween()
			tween.tween_property(%Panel2_3, "self_modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween.finished
		4:
			var tween1 = create_tween()
			tween1.tween_property(%Screen2, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween1.finished
			
			var tween2 = create_tween()
			tween2.tween_property(%Screen3, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			await tween2.finished
		5:
			var tween = create_tween()
			tween.tween_property(%Panel3_2, "position:x", 240, 1.0).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			await tween.finished
	progress += 1
	await get_tree().create_timer(0.8).timeout
	if progress < 6:
		click_active = true
		%Mouse.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0).timeout
	%Mouse.visible = true
	click_active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_click_area_gui_input(event):
	if click_active and event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()
