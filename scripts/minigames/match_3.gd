extends Control

@export var grid_width: int
@export var grid_height: int
@export var spacing: int

const tiles = {
	"bone": preload("res://scenes/minigames/match_3_bone.tscn"),
	"flower": preload("res://scenes/minigames/match_3_flower.tscn"),
	"meat": preload("res://scenes/minigames/match_3_meat.tscn"),
	"moon": preload("res://scenes/minigames/match_3_moon.tscn"),
	"paw": preload("res://scenes/minigames/match_3_paw.tscn")
}

const colors = ["bone", "flower", "meat", "moon", "paw"]

var swipe_start
var swipe_end

var tiles_in_play: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_tiles()

func _find_matches_at_tile(tile_pos: Vector2i, color: String):
	var i = tile_pos.y
	var j = tile_pos.x
	var matches = {}
	if i > 1:
		if tiles_in_play[i-1][j][0] != null and tiles_in_play[i-2][j][0] != null:
			if tiles_in_play[i-1][j][0].color == color and tiles_in_play[i-2][j][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j, i-1)] = null
				matches[Vector2i(j, i-2)] = null
	
	if j > 1:
		if tiles_in_play[i][j-1][0] != null and tiles_in_play[i][j-2][0] != null:
			if tiles_in_play[i][j-1][0].color == color and tiles_in_play[i][j-2][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j-1, i)] = null
				matches[Vector2i(j-2, i)] = null
	
	if i < grid_height - 2:
		if tiles_in_play[i+1][j][0] != null and tiles_in_play[i+2][j][0] != null:
			if tiles_in_play[i+1][j][0].color == color and tiles_in_play[i+2][j][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j, i+1)] = null
				matches[Vector2i(j, i+2)] = null
	
	if j < grid_width - 2:
		if tiles_in_play[i][j+1][0] != null and tiles_in_play[i][j+2][0] != null:
			if tiles_in_play[i][j+1][0].color == color and tiles_in_play[i][j+2][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j+1, i)] = null
				matches[Vector2i(j+2, i)] = null
	
	if i < grid_height - 1 and i > 0:
		if tiles_in_play[i-1][j][0] != null and tiles_in_play[i+1][j][0] != null:
			if tiles_in_play[i-1][j][0].color == color and tiles_in_play[i+1][j][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j, i-1)] = null
				matches[Vector2i(j, i+1)] = null
	
	if j < grid_width - 1 and j > 0:
		if tiles_in_play[i][j-1][0] != null and tiles_in_play[i][j+1][0] != null:
			if tiles_in_play[i][j-1][0].color == color and tiles_in_play[i][j+1][0].color == color:
				matches[Vector2i(j, i)] = null
				matches[Vector2i(j-1, i)] = null
				matches[Vector2i(j+1, i)] = null
	
	if matches.keys().size() == 0:
		return null
	
	return matches.keys()

func _generate_tiles():
	for i in range(grid_height):
		var row = []
		for j in range(grid_width):
			row.append([null, _grid_to_pixel(i, j)])
		tiles_in_play.append(row)
	
	for i in range(grid_height):
		for j in range(grid_width):
			var tile = tiles[colors[randi_range(0, colors.size()-1)]].instantiate()
			while _find_matches_at_tile(Vector2i(j, i), tile.color) != null:
				tile = tiles[colors[randi_range(0, colors.size()-1)]].instantiate()
			tile.position = _grid_to_pixel(i, j)
			tiles_in_play[i][j][0] = tile
			add_child(tile)

func _grid_to_pixel(i, j):
	if i < 0 or j < 0 or i >= grid_height or j >= grid_width:
		return null
	return Vector2i(j*spacing, i*spacing)

func _pixel_to_grid(pos):
	var j = int(pos.x)/spacing
	var i = int(pos.y)/spacing
	if i >= grid_height or j >= grid_width or i < 0 or j < 0:
		return null
	return Vector2i(j, i)

func _drop_tiles(empty_coords: Array):
	if empty_coords.size() == 0:
		return
	
	# find all the "top" empty coords (i.e., those with tiles above them that need to fall)
	# check if there are any empty coords above this one and exclude if so
	var top_coords = empty_coords.filter(func(coord): return Vector2i(coord.x, coord.y - 1) not in empty_coords)
	
	top_coords.sort_custom(func(a, b): return b.y > a.y)
	var coords_to_check_for_combos = []
	var tweens = []
	for coord in top_coords:
		if coord.y == 0 or tiles_in_play[coord.y-1][coord.x][0] == null:
			continue
		
		var tile_coords_to_drop = []
		for i in range(coord.y):
			if tiles_in_play[i][coord.x][0] == null:
				continue
			tile_coords_to_drop.append(Vector2i(coord.x, i))
		
		if tile_coords_to_drop.size() == 0:
			continue
		
		var spaces_to_drop = 1
		if coord.y < grid_height - 1:
			for i in range(coord.y + 1, grid_height):
				if tiles_in_play[i][coord.x][0] == null:
					spaces_to_drop += 1
				else:
					break
		
		# this might be a recursive call
		# so we need to account for empty spaces on top of the stack
		# in the later loop where we null the dropped tiles
		var empty_spaces_above = 0
		var top_dropped_row = tile_coords_to_drop.map(func(coord): return coord.y).min()
		for i in range(top_dropped_row):
			if tiles_in_play[i][coord.x][0] == null:
				empty_spaces_above += 1
		
		tile_coords_to_drop.reverse()
		for drop_coord in tile_coords_to_drop:
			var tween = create_tween()
			tweens.append(tween)
			tween.tween_property(tiles_in_play[drop_coord.y][drop_coord.x][0], "position", Vector2(tiles_in_play[drop_coord.y + spaces_to_drop][drop_coord.x][1]), 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tiles_in_play[drop_coord.y + spaces_to_drop][drop_coord.x][0] = tiles_in_play[drop_coord.y][drop_coord.x][0]
			coords_to_check_for_combos.append(Vector2i(drop_coord.x, drop_coord.y + spaces_to_drop))
		
		if tile_coords_to_drop.size() > 0:
			for i in range(top_dropped_row, top_dropped_row+spaces_to_drop):
				tiles_in_play[i][coord.x][0] = null
			
	if tweens.size() > 0:
		await tweens[0].finished
	
	var total_combo_coords = []
	for coord in coords_to_check_for_combos:
		if tiles_in_play[coord.y][coord.x][0] == null:
			continue
		var matches = _find_matches_at_tile(coord, tiles_in_play[coord.y][coord.x][0].color)
		if matches != null:
			total_combo_coords.append_array(matches)
			await _handle_matches(matches)
	await _drop_tiles(total_combo_coords)

func _replace_tiles():
	var coords_to_replace = []
	for i in range(grid_height):
		for j in range(grid_width):
			if tiles_in_play[i][j][0] == null:
				coords_to_replace.append(Vector2i(j, i))
	
	for coord in coords_to_replace:
		var tile = tiles[colors[randi_range(0, colors.size()-1)]].instantiate()
		while _find_matches_at_tile(Vector2i(coord.x, coord.y), tile.color) != null:
			tile = tiles[colors[randi_range(0, colors.size()-1)]].instantiate()
		tile.position = _grid_to_pixel(coord.y, coord.x)
		tiles_in_play[coord.y][coord.x][0] = tile
		tile.scale = Vector2(0, 0)
		add_child(tile)
		var tween = create_tween()
		tween.tween_property(tile, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _handle_matches(tile_coords: Array):
	var tweens = []
	for coord in tile_coords:
		var tile = tiles_in_play[coord.y][coord.x][0]
		var tween = create_tween()
		tween.tween_property(tile, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.tween_callback(tile.queue_free)
		tweens.append(tween)
		tiles_in_play[coord.y][coord.x][0] = null
	await tweens[0].finished

func _check_for_matches(first: Vector2i, second: Vector2i):
	var first_matches = _find_matches_at_tile(first, tiles_in_play[first.y][first.x][0].color)
	var total_matches = []
	if first_matches != null:
		total_matches.append_array(first_matches)
		await _handle_matches(first_matches)
	
	var second_matches = _find_matches_at_tile(second, tiles_in_play[second.y][second.x][0].color)
	if second_matches != null:
		total_matches.append_array(second_matches)
		#if first_matches != null:
			#await get_tree().create_timer(0.1).timeout
		await _handle_matches(second_matches)
	
	await _drop_tiles(total_matches)
	_replace_tiles()

var _currently_swapping = false
func _swap_tiles(first: Vector2i, second: Vector2i):
	if _currently_swapping:
		return
	
	var finalize_swap = func(first: Vector2i, second: Vector2i):
		var temp = tiles_in_play[first.y][first.x][0]
		tiles_in_play[first.y][first.x][0] = tiles_in_play[second.y][second.x][0]
		tiles_in_play[second.y][second.x][0] = temp
		_check_for_matches(first, second)
		_currently_swapping = false
	
	_currently_swapping = true
	get_tree().create_timer(0.1).timeout.connect(func(): %Match3SlideSFX.play())
	
	var tile_tween = create_tween()
	var temp = Vector2(tiles_in_play[first.y][first.x][1])
	tile_tween.tween_property(tiles_in_play[first.y][first.x][0], "position", Vector2(tiles_in_play[second.y][second.x][1]), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tile_tween.parallel().tween_property(tiles_in_play[second.y][second.x][0], "position", temp, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tile_tween.tween_callback(finalize_swap.bind(first, second))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
enum SwipeDirection {
	UP, DOWN, LEFT, RIGHT
}

func _find_swap_direction(first: Vector2i, second: Vector2i):
	if first.x == second.x and first.y == second.y:
		return null
	
	if first.x == second.x:
		if first.y < second.y:
			return SwipeDirection.DOWN
		else:
			return SwipeDirection.UP
	elif first.y == second.y:
		if first.x < second.x:
			return SwipeDirection.RIGHT
		else:
			return SwipeDirection.LEFT

func _on_gui_input(event):
	if event is InputEventMouseButton:
		print(event)
		if event.pressed:
			swipe_start = _pixel_to_grid(event.position)
		else:
			swipe_end = _pixel_to_grid(event.position)
			if swipe_end == null:
				swipe_start = null
			elif swipe_start != null:
				var direction = _find_swap_direction(swipe_start, swipe_end)
				if direction != null:
					match direction:
						SwipeDirection.DOWN:
							_swap_tiles(swipe_start, Vector2i(swipe_start.x, swipe_start.y+1))
						SwipeDirection.UP:
							_swap_tiles(swipe_start, Vector2i(swipe_start.x, swipe_start.y-1))
						SwipeDirection.RIGHT:
							_swap_tiles(swipe_start, Vector2i(swipe_start.x+1, swipe_start.y))
						SwipeDirection.LEFT:
							_swap_tiles(swipe_start, Vector2i(swipe_start.x-1, swipe_start.y))
