extends Node2D
@onready var normal_rooms = load_rooms("res://Floor1/scenes/Rooms/Normal/")
@onready var top_layer = {
	"earth" : load_rooms("res://Floor1/scenes/Rooms/top_layer/earth/"),
	"midair" : load_rooms("res://Floor1/scenes/Rooms/top_layer/midair/")
	#"start" : load("res://Floor1/scenes/Rooms/top_layer/Room_Start.tscn"),
	#"end" : load("res://Floor1/scenes/Rooms/top_layer/Room_End.tscn")
}
@onready var sub_layer = {
	
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

func _ready():
	rng.randomize()
	grid_w = rng.randi_range(5, 10)
	#grid_h = rng.randi_range(1, 3)
	grid_h = 1
	grid_l = rng.randi_range(5, grid_w*grid_h)

var rng = RandomNumberGenerator.new()
var grid : Array[Array] = []

func generate_grid(x, y, section, prior):
	grid[y][x].get_node("room_info").keyword = "Visited"
	var curr = {
		"connected" : true,
		"x" : x,
		"y" : y,
		"section" : section
	}
	var selection = []
	if y == 0:
		selection = top_layer[section]
	else:
		selection = sub_layer[section]
	#print("Checkpoint 1 ", selection)
	var polarity = true
	if y != 0:
		polarity = prior["connected"]
	selection = search(selection, "start", grid[y][x].get_node("room_info").start)
	selection = search(selection, "end", grid[y][x].get_node("room_info").end)
	#print("Checkpoint 2 ", selection)
	if prior["x"] < x:
		selection = search(selection, "left", polarity)
	elif prior["x"] > x:
		selection = search(selection, "right", polarity)
	elif prior["y"] > y:
		selection = search(selection, "bottom", polarity)
	elif prior["y"] < y:
		selection = search(selection, "top", polarity)
	var directions = [[x, y-1, "top"], [x+1, y, "right"], [x, y+1, "bottom"], [x-1, y, "left"]]
	directions.shuffle()
	for pairing in directions:
		#print("Begin Pairing ", selection)
		if pairing[0] >= 0 and pairing[0] < grid_w and pairing[1] >= 0 and pairing[1] < grid_h:
			curr["connected"] = grid[pairing[1]][pairing[0]].get_node("room_info").section == section
			polarity = true
			if y != 0:
				polarity = curr["connected"]
			if grid[pairing[1]][pairing[0]].get_node("room_info").keyword == "Placeholder":
				selection = search(selection, pairing[2], polarity)
				#print("Recursion")
				generate_grid(pairing[0], pairing[1], grid[pairing[1]][pairing[0]].get_node("room_info").section, curr)
				#print("Finish Recursion")
		else:
			#print("Before ", pairing[0], ", ", pairing[1],": ", selection)
			selection = search(selection, pairing[2], false)
			#print("After ", pairing[0], ", ", pairing[1], ", ", pairing[2], ": ", selection)
	grid[y][x] = load(selection.pick_random()).instantiate()
	
func search(array, attribute, polarity) -> Array:
	var trimmed = []
	for room in array:
		var temp = load(room).instantiate()
		if temp.get_node("room_info").get(attribute) == polarity:
			trimmed.push_back(room)
	return trimmed
	
func search_keyword(array, keyword) -> Array:
	var trimmed = []
	for room in array:
		var temp = load(room).instantiate()
		if temp.get_node("room_info").get("keyword") == keyword:
			trimmed.push_back(room)
	return trimmed

func room_generation() -> Array:
	rng.randomize()
	
	for row in range(0, grid_h):
		grid.push_back([])
		for col in range(0, grid_w):
			grid[row].push_back(load("res://Floor1/scenes/Rooms/Room_Placeholder.tscn").instantiate())
			grid[row][col].position.x = room_w * col
	#grid[0][rng.randi_range(0, grid_w)] = top_layer
	var temp = range(1, grid_w-1)
	for i in range(0, grid_w/3):
		var index = temp.pick_random()
		grid[0][index].get_node("room_info").section = "switch"
		temp.erase(index)
	var switch = false;
	for col in range(0, grid_w-1):
			if grid[0][col].get_node("room_info").section == "switch":
				if switch:
					for row in range(0, grid_h):
						grid[row][col].get_node("room_info").section = "midair"
						grid[row][col].get_node("room_info").end = true
				else:
					for row in range(0, grid_h):
						grid[row][col].get_node("room_info").section = "midair"
						grid[row][col].get_node("room_info").start = true
				switch = !switch
			elif switch:
				for row in range(0, grid_h):
					grid[row][col].get_node("room_info").section = "midair"
			else:
				for row in range(0, grid_h):
					grid[row][col].get_node("room_info").section = "earth"
	for row in range(0, grid_h):
		grid[row][grid_w-1].get_node("room_info").section = "earth"
	temp = rng.randi_range(0, grid_w-1)
	#var counter = 0
	while(grid[0][temp].get_node("room_info").section != "earth"):
		temp = rng.randi_range(0, grid_w-1)
		#print(temp)
		#print(grid[0][temp].get_node("room_info").section)
		#counter = counter + 1
	grid[0][temp].get_node("room_info").start = true
	#print("Section of Start: ", grid[0][temp].get_node("room_info").section)
	var temp2 = rng.randi_range(0, grid_w-1)
	while(grid[0][temp2].get_node("room_info").section != "earth" or temp2 == temp):
		temp2 = rng.randi_range(0, grid_w-1)
	grid[0][temp2].get_node("room_info").end = true
	#print("Section of End: ", grid[0][temp2].get_node("room_info").section)
	var spawn_point = Vector2(room_w * temp, room_h * 0)
	generate_grid(temp, 0, "earth", {"connected" : true, "x" : temp, "y" : 0, "section" : "earth"})
	#rooms.push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_Start.tscn").instantiate())
	#add_child.call_deferred(rooms[0])
	#for i in range(1, rng.randi_range(5, 7)):
		#rooms.push_back(load(top_layer["earth"].pick_random()).instantiate())
		#rooms[i].position.x = room_w * i
		#add_child.call_deferred(rooms[i])
	#rooms.push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_End.tscn").instantiate())
	#rooms[rooms.size()-1].position.x = room_w * (rooms.size()-1)
	#add_child.call_deferred(rooms[rooms.size()-1])
	#return [Vector2(room_w * (rooms.size()-1)+240, room_h)]
	for row in range(0, grid_h):
		for col in range(0, grid_w):
			grid[row][col].position = Vector2(room_w * col, room_h * row)
			add_child.call_deferred(grid[row][col])
	for col in range(0, grid_w):
		borders["sky"].push_back(load("res://Floor1/scenes/Rooms/Room_Sky.tscn").instantiate())
		borders["sky"][borders["sky"].size()-1].position = Vector2(room_w * borders["sky"].size()-1, -1 * room_h)
		add_child.call_deferred(borders["sky"][col])
	return [Vector2(room_w * (grid[0].size()-1)+240, room_h * (grid.size()-1)), spawn_point]

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
