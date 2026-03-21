extends Node2D
@onready var normal_rooms = load_rooms("res://Floor1/scenes/Rooms/Normal/")
@onready var top_layer = {
	"earth" : load_rooms("res://Floor1/scenes/Rooms/top_layer/earth/"),
	"midair" : load_rooms("res://Floor1/scenes/Rooms/top_layer/midair/"),
	"special" : load_rooms("res://Floor1/scenes/Rooms/top_layer/special/")
}
@onready var sub_layer = {
	"earth" : load_rooms("res://Floor1/scenes/Rooms/sub_layer/earth/"),
	"midair" : load_rooms("res://Floor1/scenes/Rooms/sub_layer/midair/"),
	"special" : load_rooms("res://Floor1/scenes/Rooms/sub_layer/special/")
}
@onready var room_info = load("res://misc/scenes/room_info.tscn")

var grid_w
var grid_h
var grid_l
var room_w = 480
var room_h = 240
var borders = {
	"sky" : [],
	"base" : []
}

var rng = RandomNumberGenerator.new()
var grid : Array[Array] = []

func _ready():
	rng.randomize()
	grid_w = 5
	grid_h = 2
	
func room_generation() -> Array:
	var start_vertical = min(GameEvents.next_floor_level, 1)
	if start_vertical == 0:
		grid = [[], []]
		grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_S02.tscn").instantiate())
		grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
		grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/boss/Room_02.tscn").instantiate())
		grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
		
	else:
		grid = [[], []]
		grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_07.tscn").instantiate())
		grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_S05.tscn").instantiate())
		grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/boss/Room_03.tscn").instantiate())
		grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_01.tscn").instantiate())
	grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/boss/Room_01.tscn").instantiate())
	grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
	grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/boss/Room_00.tscn").instantiate())
	grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
	grid[0].push_back(load("res://Floor1/scenes/Rooms/top_layer/boss/Room_E00.tscn").instantiate())
	grid[1].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
	for row in range(0, grid_h):
		for col in range(0, grid_w):
			grid[row][col].position = Vector2(room_w * col, room_h * row)
			add_child.call_deferred(grid[row][col])
	return [Vector2(room_w * (grid[0].size()-1)+240, room_h * (grid.size()-1)), Vector2(0, start_vertical * room_h + 40)]


func search(array, attribute, polarity) -> Array:
	var trimmed = []
	for room in array:
		var temp = load(room).instantiate()
		if temp.get_node("room_info").get(attribute) == polarity:
			trimmed.push_back(room)
	return trimmed
	
func search_keyword(array, keyword, value) -> Array:
	var trimmed = []
	for room in array:
		var temp = load(room).instantiate()
		if temp.get_node("room_info").get(keyword) == value:
			trimmed.push_back(room)
	return trimmed
	
func search_array(array, attribute, value) -> Array:
	var trimmed = []
	for room in array:
		var temp = load(room).instantiate()
		if temp.get_node("room_info").get(attribute).has(value):
			trimmed.push_back(room)
	return trimmed

func load_rooms(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				files.append(path.path_join(file_name))
			file_name = dir.get_next()
	return files
