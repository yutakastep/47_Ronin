extends Node2D
@onready var normal_rooms = load_rooms("res://Floor1/scenes/Rooms/Normal/")
@onready var top_layer = {
	"earth" : load_rooms("res://Floor1/scenes/Rooms/top_layer/earth/"),
	"midair" : load_rooms("res://Floor1/scenes/Rooms/top_layer/midair/")
	#"start" : load("res://Floor1/scenes/Rooms/top_layer/Room_Start.tscn"),
	#"end" : load("res://Floor1/scenes/Rooms/top_layer/Room_End.tscn")
}
@onready var sub_layer = {
	"earth" : load_rooms("res://Floor1/scenes/Rooms/sub_layer/earth/"),
	"midair" : load_rooms("res://Floor1/scenes/Rooms/sub_layer/midair/")
}
@onready var room_info = load("res://misc/scenes/room_info.tscn")

var grid_w
var grid_h
var grid_l
var room_w = 480
var room_h = 240
var borders = {
	"sky" : [],
	"base" : [],
	"sides" : []
}
var end_coords : Vector2
var end_found = false
var end_invalid = false

var room_cache = {}

func _ready():
	cache_all_rooms()
	rng.randomize()
	grid_w = rng.randi_range(10, 15)
	grid_h = rng.randi_range(2, 4)
	#grid_h = 2
	if grid_h < GameEvents.next_floor_level:
		grid_h = GameEvents.next_floor_level
	
	grid_l = rng.randi_range(3, (grid_w*grid_h)/3)

var rng = RandomNumberGenerator.new()
var grid : Array[Array] = []

func cache_all_rooms():
	var all_paths = []
	for key in top_layer: all_paths.append_array(top_layer[key])
	for key in sub_layer: all_paths.append_array(sub_layer[key])
	for path in all_paths:
		var room_node = load(path).instantiate()
		var info = room_node.get_node("room_info")
		room_cache[path] = {
			"left": info.left,
			"right": info.right,
			"top": info.top,
			"bottom": info.bottom,
			"start": info.start,
			"end": info.end,
			"section": info.section,
			"keyword": info.keyword,
			"x": info.x,
			"y": info.y,
			"associated_room": info.associated_room
		}
		room_node.free()

func generate_grid(x, y, section, prior):
	if Vector2(x, y) == end_coords:
		end_found = true
	if section == "midair" and y != 0:
		return
	grid[y][x].get_node("room_info").keyword = "Visited"
	var curr = {
		"connected" : true,
		"x" : x,
		"y" : y,
		"section" : section
	}
	var selection = []
	if y == 0:
		#print("section=", section)
		selection = top_layer[section]
	else:
		#print("section=",section)
		selection = sub_layer[section]
	#print("Checkpoint 1 ", selection)
	var polarity = true
	#if y != 0:
		#polarity = prior["connected"]
	selection = search(selection, "start", grid[y][x].get_node("room_info").start)
	selection = search(selection, "end", grid[y][x].get_node("room_info").end)
	##print("Checkpoint 2 ", selection)
	var directions = [[x, y-1, "top", "bottom"], [x+1, y, "right", "left"], [x, y+1, "bottom", "top"], [x-1, y, "left", "right"]]
	var valid_direction = {
		"top" : true,
		"bottom" : true,
		"left" : true,
		"right" : true
	}
	#Check Adjacent Nodes to see if any additional restrictions on selection need to be made
	for pairing in directions:
		#print("Begin Pairing ", selection)
		if pairing[0] >= 0 and pairing[0] < grid_w and pairing[1] >= 0 and pairing[1] < grid_h:
			curr["connected"] = grid[pairing[1]][pairing[0]].get_node("room_info").section == section
			polarity = grid[pairing[1]][pairing[0]].get_node("room_info").get(pairing[3])
			if y != 0 and !curr["connected"]:
				#print("Condition: y != 0 and !curr[connected]")
				#print("Before ", pairing[0], ", ", pairing[1],": ", selection)
				selection = search(selection, pairing[2], false)
				valid_direction[pairing[2]] = false
			elif grid[pairing[1]][pairing[0]].get_node("room_info").keyword == "Visited":
				#print("Condition: pairing has been visited before")
				#print(pairing[2], ", ", polarity)
				#print("Before ", pairing[0], ", ", pairing[1],": ", selection)
				selection = search(selection, pairing[2], polarity)
		else:
			#print("Condition: pairing out of boounds")
			#print("Before ", pairing[0], ", ", pairing[1],": ", selection)
			selection = search(selection, pairing[2], false)
			valid_direction[pairing[2]] = false
			#print("After ", pairing[0], ", ", pairing[1], ", ", pairing[2], ": ", selection)
	print("[", x, ", ", y, "] ", selection, grid[y][x].get_node("room_info").left, grid[y][x].get_node("room_info").right, grid[y][x].get_node("room_info").top, grid[y][x].get_node("room_info").bottom, grid[y][x].get_node("room_info").start, grid[y][x].get_node("room_info").end, section)
	#Make it more likely that terrain generates towards end of floor
	if !end_found:
		var flag = rng.randi_range(0, 1)
		if flag == 0 and x < end_coords.x and valid_direction["right"]:
			selection = search(selection, "right", true)
		elif flag == 0 and x > end_coords.x and valid_direction["left"]:
			selection = search(selection, "left", true)
	#Assuming a room under the restrictions exists, assign it to grid spot
	if selection.size() > 0:
		grid[y][x] = load(selection.pick_random()).instantiate()
		grid[y][x].get_node("room_info").keyword = "Visited"
		grid[y][x].get_node("room_info").x = x
		grid[y][x].get_node("room_info").y = y
	elif section == "earth" and grid[y][x].get_node("room_info").end:
		end_invalid = true
		
	#Continue Traversing grid
	directions.shuffle()
	for pairing in directions:
		#print("Begin Pairing ", selection)
		if pairing[0] >= 0 and pairing[0] < grid_w and pairing[1] >= 0 and pairing[1] < grid_h:
			curr["connected"] = grid[pairing[1]][pairing[0]].get_node("room_info").section == section
			if y != 0 and !curr["connected"]:
				selection = search(selection, pairing[2], false)
			if (y == 0 or curr["connected"]) and grid[pairing[1]][pairing[0]].get_node("room_info").keyword == "Placeholder":
				selection = search(selection, pairing[2], polarity)
				#print("Recursion")
				generate_grid(pairing[0], pairing[1], grid[pairing[1]][pairing[0]].get_node("room_info").section, curr)
				#print("Finish Recursion")
	
func search(array, attribute, polarity) -> Array:
	var trimmed = []
	for path in array:
		if room_cache[path][attribute] == polarity:
			trimmed.push_back(path)
	return trimmed
	
func search_keyword(array, keyword, value) -> Array:
	var trimmed = []
	for path in array:
		if room_cache[path][keyword] == value:
			trimmed.push_back(path)
	return trimmed
	
func search_array(array, attribute, value) -> Array:
	var trimmed = []
	for path in array:
		if room_cache[path][attribute].has(value):
			trimmed.push_back(path)
	return trimmed
	
func default_grid() -> Array:
	grid = []
	for row in range(0, grid_h):
		grid.push_back([])
		for col in range(0, grid_w):
			grid[row].push_back(load("res://Floor1/scenes/Rooms/Room_Placeholder.tscn").instantiate())
			grid[row][col].position.x = room_w * col
	var temp = range(1, grid_w-2)
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
	if switch: 
		for row in range(0, grid_h):
			grid[row][grid_w-2].get_node("room_info").section = "midair"
			grid[row][grid_w-2].get_node("room_info").end = true
	for row in range(0, grid_h):
		grid[row][grid_w-1].get_node("room_info").section = "earth"
	var start_vertical = min(GameEvents.next_floor_level, 1)
	var start_horizontal = rng.randi_range(0, grid_w-1)
	#var counter = 0
	while(grid[start_vertical][start_horizontal].get_node("room_info").section != "earth"):
		start_horizontal = rng.randi_range(0, grid_w-1)
		#print(temp)
		#print(grid[0][temp].get_node("room_info").section)
		#counter = counter + 1
	grid[start_vertical][start_horizontal].get_node("room_info").start = true
	#print("Section of Start: ", grid[0][temp].get_node("room_info").section)
	var end_vertical = rng.randi_range(0, grid_h-1)
	var end_horizontal = rng.randi_range(0, grid_w-1)
	while(grid[end_vertical][end_horizontal].get_node("room_info").section != "earth" or abs(end_horizontal - start_horizontal) + abs(end_vertical - start_vertical) < grid_l):
		end_vertical = rng.randi_range(0, grid_h-1)
		end_horizontal = rng.randi_range(0, grid_w-1)
	grid[end_vertical][end_horizontal].get_node("room_info").end = true
	return [Vector2(start_horizontal, start_vertical), Vector2(end_horizontal, end_vertical)]

func room_generation() -> Array:
	rng.randomize()
	
	
	#grid[0][rng.randi_range(0, grid_w)] = top_layer
	
	#print("Section of End: ", grid[0][temp2].get_node("room_info").section)
	var start_end_location = [Vector2(0, 0), Vector2(-1, -1)]
	var spawn_point = Vector2(0, 0)
	var grid_check_queue = []
	var visited = []
	while !visited.has(start_end_location[1]) or end_invalid:
		#dprint("Stuck in Loop")
		start_end_location = default_grid()
		end_coords = start_end_location[1]
		end_invalid = false
		generate_grid(start_end_location[0].x, start_end_location[0].y, "earth", {"connected" : true, "x" : start_end_location[0].x, "y" : start_end_location[0].y, "section" : "earth"})
		spawn_point = Vector2(room_w * start_end_location[0].x, room_h * start_end_location[0].y + 40)
		grid_check_queue = [start_end_location[0]]
		visited = []
		while grid_check_queue.size() > 0:
			#print("Stuck in Loop 2 ", grid_check_queue)
			var curr = grid_check_queue.pop_front()
			var x = curr.x
			var y = curr.y
			var directions = [[x, y-1, "top"], [x+1, y, "right"], [x, y+1, "bottom"], [x-1, y, "left"]]
			for pairing in directions:
				if pairing[0] >= 0 and pairing[1] >= 0 and !visited.has(Vector2(pairing[0], pairing[1])) and grid[y][x].get_node("room_info").get(pairing[2]):
					visited.push_back(Vector2(pairing[0], pairing[1]))
					grid_check_queue.push_back(Vector2(pairing[0], pairing[1]))
	GameEvents.next_floor_level = end_coords.y
	
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
	var clean_up = sub_layer["midair"]
	for col in range(0, grid_w):
		if grid[0][col].get_node("room_info").section == "midair":
			if grid_h == 2:
				clean_up = sub_layer["midair"]
				clean_up = search_array(clean_up, "associated_room", grid[0][col].scene_file_path)
				clean_up = search_keyword(clean_up, "keyword", "1_Tall_Bottom")
				if clean_up.size() > 0:
					grid[1][col] = load(clean_up.pick_random()).instantiate()
				else:
					print("h == 2 Clean Up Failed For ", grid[0][col].scene_file_path)
			else:
				for i in range(1, grid_h-2):
					clean_up = sub_layer["midair"]
					clean_up = search_array(clean_up, "associated_room", grid[0][col].scene_file_path)
					clean_up = search_keyword(clean_up, "keyword", "Filler")
					if clean_up.size() > 0:
						grid[i][col] = load(clean_up.pick_random()).instantiate()
					else:
						print("Clean Up Failed for ", grid[0][col].scene_file_path)
				clean_up = sub_layer["midair"]
				clean_up = search_array(clean_up, "associated_room", grid[0][col].scene_file_path)
				clean_up = search_keyword(clean_up, "keyword", "2_Tall_Top")
				if clean_up.size() > 0:
					grid[grid_h-2][col] = load(clean_up.pick_random()).instantiate()
				else:
					print("Clean Up Failed for ", grid[0][col].scene_file_path)
				clean_up = sub_layer["midair"]
				clean_up = search_array(clean_up, "associated_room", grid[0][col].scene_file_path)
				clean_up = search_keyword(clean_up, "keyword", "2_Tall_Bottom")
				if clean_up.size() > 0:
					print(clean_up)
					grid[grid_h-1][col] = load(clean_up.pick_random()).instantiate()
				else:
					print("Clean Up Failed for ", grid[0][col].scene_file_path)
	for row in range(0, grid_h):
		for col in range(0, grid_w):
			grid[row][col].position = Vector2(room_w * col, room_h * row)
			add_child.call_deferred(grid[row][col])
	for col in range(0, grid_w):
		borders["sky"].push_back(load("res://Floor1/scenes/Rooms/Room_Sky.tscn").instantiate())
		borders["sky"][borders["sky"].size()-1].position = Vector2(room_w * (borders["sky"].size()-1), -1 * room_h)
		add_child.call_deferred(borders["sky"][col])
		borders["base"].push_back(load("res://Floor1/scenes/Rooms/sub_layer/earth/Room_15.tscn").instantiate())
		borders["base"][borders["base"].size()-1].position = Vector2(room_w * (borders["sky"].size()-1), grid.size() * room_h)
		add_child.call_deferred(borders["base"][col])
	borders["sides"].push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_07.tscn").instantiate())
	borders["sides"][borders["sides"].size()-1].position = Vector2(room_w * -1, 0)
	add_child.call_deferred(borders["sides"][borders["sides"].size()-1])
	borders["sides"].push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_07.tscn").instantiate())
	borders["sides"][borders["sides"].size()-1].position = Vector2(room_w * grid_w, 0)
	add_child.call_deferred(borders["sides"][borders["sides"].size()-1])
	for row in range(1, grid_h+1):
		borders["sides"].push_back(load("res://Floor1/scenes/Rooms/top_layer/earth/Room_07.tscn").instantiate())
		borders["sides"][borders["sides"].size()-1].position = Vector2(room_w * -1, row)
		add_child.call_deferred(borders["sides"][borders["sides"].size()-1])
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
