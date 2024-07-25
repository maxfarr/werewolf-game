extends Control

var instructions = []
@onready var instruction_visuals = [
	%mouse_instruction, %mouse_instruction2, %mouse_instruction3, %mouse_instruction4, %mouse_instruction5
]
var current_instruction = 0
var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_instruction = 0
	running = false
	_generate_instructions()
	var tween = create_tween()
	tween.tween_property(%Hand, "position:y", 112, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_start_game)
	
	%Hand.play("shake")
	
	SignalBus.hand_clicked.connect(_handle_click)

func _generate_instructions():
	for i in range(5):
		var instruction = randi_range(0, 1)
		instructions.append(instruction)
		if instruction == 1:
			instruction_visuals[i].flip_h = true

func _start_game():
	running = true
	%MinigameTimer.visible = true
	%MinigameTimer.failure.connect(_lose_animation)
	%MinigameTimer._start(5.0)
	%Background.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _lose_animation():
	%Background.visible = false
	%MinigameTimer.visible = false
	%Hand.play("fist")
	var tween = create_tween()
	tween.tween_property(%Hand, "position:y", 210, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.5)
	tween.tween_callback(func(): SignalBus.minigame_failed.emit())

func _win_animation():
	%Background.visible = false
	%MinigameTimer.failure.disconnect(_lose_animation)
	%MinigameTimer.visible = false
	%Hand.play("thumbs_up")
	var tween = create_tween()
	tween.tween_property(%Hand, "position:y", 210, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.5)
	tween.tween_callback(func(): SignalBus.minigame_succeeded.emit())

func _handle_click(mouse_button):
	if running:
		if mouse_button - 1 == instructions[current_instruction]:
			instruction_visuals[current_instruction].visible = false
			if current_instruction == 4:
				running = false
				_win_animation()
			current_instruction += 1
		else:
			_lose_animation()
