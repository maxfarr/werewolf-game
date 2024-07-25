extends Control

var max_eye_speed = 2.0
var max_target_speed = 1.5
var eye_accel = Vector2(0.05, 0.0)
var eye_velocity = Vector2(0.0, 0.0)
var target_velocity = Vector2(0.0, 0.0)

var target_update_timer : Timer
var minigame_timer : Timer

var _noise = FastNoiseLite.new()

var target_active = false
var fill_speed = 50

@export var time = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	target_update_timer = Timer.new()
	target_update_timer.one_shot = false
	target_update_timer.wait_time = 0.5
	target_update_timer.timeout.connect(_update_target_movement)
	add_child(target_update_timer)
	target_update_timer.start()
	
	%MinigameTimer.failure.connect(func(): SignalBus.minigame_failed.emit())
	%MinigameTimer._start(time)

func _update_target_movement():
	target_velocity = Vector2(_noise.get_noise_1d(Time.get_ticks_msec()), 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_mouse_button_pressed(1) and get_viewport().get_mouse_position().x < GameState.SCREEN_DIVISION_X:
		eye_accel = Vector2(0.12, 0.0)
	else:
		eye_accel = Vector2(-0.12, 0.0)
	
	if eye_velocity.x + eye_accel.x > max_eye_speed:
		eye_velocity.x = max_eye_speed
	elif eye_velocity.x + eye_accel.x < -max_eye_speed:
		eye_velocity.x = -max_eye_speed
	else:
		eye_velocity += eye_accel
		
	#var target_accel = Vector2(randf_range(-0.1, 0.1), 0.0)
	#
	#if target_velocity.x + target_accel.x > max_target_speed:
		#target_velocity.x = max_target_speed
	#elif target_velocity.x + target_accel.x < -max_target_speed:
		#target_velocity.x = -max_target_speed
	#else:
		#target_velocity += target_accel
		
	
	%Eye.move_and_collide(eye_velocity)
	%Target.move_and_collide(target_velocity)
	
	if target_active:
		%Progress.value += %Progress.step * fill_speed
		if %Progress.value >= %Progress.max_value:
			SignalBus.minigame_succeeded.emit()

func _on_area_2d_body_entered(body):
	target_active = true


func _on_area_2d_body_exited(body):
	target_active = false # Replace with function body.
