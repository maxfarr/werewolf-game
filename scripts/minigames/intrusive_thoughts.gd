extends Control

const min_x = -117
const max_x = 21

const min_y = -63
const max_y = 93

const min_popup_distance = 25.0

var popups_remaining = 0

var popup = preload("res://scenes/minigames/intrusive_thought.tscn")
var popups = []

var running = false

func _generate_positions():
	var done = false
	while not done:
		var positions = []
		done = true
		for i in range(popups_remaining):
			var new_pos = Vector2(randi_range(min_x, max_x), randi_range(min_y, max_y))
			for pos in positions:
				if pos.x == new_pos.x or pos.y == new_pos.y or new_pos.distance_to(pos) < min_popup_distance:
					done = false
					break
			if not done:
				break
			positions.append(new_pos)
		
		if done:
			return positions

func _handle_popup_closed(id):
	if running:
		%ClickSFX.play()
		popups[id].queue_free()
		popups_remaining -= 1
		if popups_remaining == 0:
			%MinigameTimer._stop()
			%MinigameTimer.visible = false
			SignalBus.minigame_succeeded.emit()
			running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	popups_remaining = GameState.intrusive_thoughts_number[GameState.level]
	
	var positions = _generate_positions()
	var random_popup_options = GameState.intrusive_thought_options.duplicate()
	random_popup_options.shuffle()
	
	for i in range(popups_remaining):
		var new_popup = popup.instantiate()
		new_popup.id = i
		new_popup.get_child(2).text = random_popup_options[i]
		new_popup.position = positions[i]
		popups.append(new_popup)
		add_child(new_popup)
	
	running = true
	SignalBus.intrusive_thought_closed.connect(_handle_popup_closed)
	%MinigameTimer.failure.connect(func():
		running = false
		SignalBus.minigame_failed.emit())
	%MinigameTimer._start(GameState.timer_durations_s["intrusive_thoughts"][GameState.level])
	%IntrusiveThoughtsSFX.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
