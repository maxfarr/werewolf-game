extends Control

@export var grid_width: int
@export var grid_height: int
@export var spacing: int

const tiles = {
	"yellow": preload("res://scenes/minigames/match_3_yellow.tscn"),
	"orange": preload("res://scenes/minigames/match_3_orange.tscn"),
	"red": preload("res://scenes/minigames/match_3_red.tscn")
}

const colors = [
	"yellow", "orange", "red"
]

var swipe_start: Vector2i
var swipe_end: Vector2i

var tiles_in_play: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_tiles()

func _placed_tile_is_match(i, j, color):
	if i > 1:
		if tiles_in_play[i-1][j] != null and tiles_in_play[i-2][j] != null:
			if tiles_in_play[i-1][j][0].color == color and tiles_in_play[i-2][j][0].color == color:
				return true
	
	if j > 1:
		if tiles_in_play[i][j-1] != null and tiles_in_play[i][j-2] != null:
			if tiles_in_play[i][j-1][0].color == color and tiles_in_play[i][j-2][0].color == color:
				return true
	
	if i < grid_height - 1 and i > 0:
		if tiles_in_play[i-1][j] != null and tiles_in_play[i+1][j] != null:
			if tiles_in_play[i-1][j][0].color == color and tiles_in_play[i+1][j][0].color == color:
				return true
			
	if j < grid_width - 1 and j > 0:
		if tiles_in_play[i][j-1] != null and tiles_in_play[i][j+1] != null:
			if tiles_in_play[i][j-1][0].color == color and tiles_in_play[i][j+1][0].color == color:
				return true
			
	return false

func _generate_tiles():
	for i in range(grid_height):
		var row = []
		for j in range(grid_width):
			row.append(null)
		tiles_in_play.append(row)
	
	for i in range(grid_height):
		for j in range(grid_width):
			var tile = tiles[colors[randi_range(0, 2)]].instantiate()
			while _placed_tile_is_match(i, j, tile.color):
				tile = tiles[colors[randi_range(0, 2)]].instantiate()
			tile.position = _grid_to_pixel(i, j)
			tiles_in_play[i][j] = [tile, tile.position]
			add_child(tiles_in_play[i][j][0])

func _grid_to_pixel(i, j):
	if i < 0 or j < 0 or i >= grid_height or j >= grid_width:
		return null
	return Vector2i(j*spacing, i*spacing)

func _pixel_to_grid(pos):
	var j = int(pos.x)/spacing
	var i = int(pos.y)/spacing
	if i >= grid_height or j >= grid_width:
		return null
	return Vector2i(j, i)

func check_for_match(first: Vector2i, second: Vector2i):
	pass

var _currently_swapping = false
func _swap_tiles(first: Vector2i, second: Vector2i):
	if _currently_swapping:
		return
	
	var finalize_swap = func(first: Vector2i, second: Vector2i):
		var temp = tiles_in_play[first.y][first.x][0]
		tiles_in_play[first.y][first.x][0] = tiles_in_play[second.y][second.x][0]
		tiles_in_play[second.y][second.x][0] = temp
		_currently_swapping = false
	
	_currently_swapping = true
	get_tree().create_timer(0.1).timeout.connect(func(): %Match3SlideSFX.play())
	
	var tween = create_tween()
	var temp = tiles_in_play[first.y][first.x][1]
	tween.tween_property(tiles_in_play[first.y][first.x][0], "position", tiles_in_play[second.y][second.x][1], 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(tiles_in_play[second.y][second.x][0], "position", temp, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(finalize_swap.bind(first, second))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _is_valid_swap(first: Vector2i, second: Vector2i):
	if first.x == second.x and abs(first.y - second.y) == 1:
		return true
	elif first.y == second.y and abs(first.x - second.x) == 1:
		return true
		
	return false

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			swipe_start = _pixel_to_grid(event.position)
		else:
			swipe_end = _pixel_to_grid(event.position)
			if swipe_start != null and _is_valid_swap(swipe_start, swipe_end):
				_swap_tiles(swipe_start, swipe_end)
