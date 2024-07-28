extends Control

class_name MinigameTimer

@export var time_sec = 0.0
signal failure
var timer : Timer
var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	running = false

func _start(duration):
	timer = Timer.new()
	timer.wait_time = duration
	time_sec = duration
	timer.one_shot = true
	timer.timeout.connect(func(): running = false; failure.emit())
	add_child(timer)
	timer.start()
	running = true

func _stop():
	timer.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if running:
		var time_remaining_fraction = timer.time_left/time_sec
		%Progress.value = %Progress.max_value * time_remaining_fraction
