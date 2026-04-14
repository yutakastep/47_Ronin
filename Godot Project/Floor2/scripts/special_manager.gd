extends "res://Floor1/scripts/special_manager.gd"

@onready var castle_layer = {
	"castle" : load_rooms("res://Floor2/scenes/Rooms/castle/"),
	"special" : load_rooms("res://Floor2/scenes/Rooms/special/")
}

func room_generation() -> Array:
	#print_orphan_nodes()
	var start_vertical = 0
	var selection = []
	grid = [[], []]
	grid[0].push_back(load("res://Floor2/scenes/Rooms/castle/Room_S06.tscn").instantiate())
	grid[1].push_back(load("res://Floor2/scenes/Rooms/castle/Room_15.tscn").instantiate())
	selection = castle_layer["special"]
	var attributes = [["left", true], ["right", true], ["top", false], ["bottom", false]]
	for pair in attributes:
		selection = search(selection, pair[0], pair[1])
	grid[0].push_back(load(selection.pick_random()).instantiate())
	grid[1].push_back(load("res://Floor2/scenes/Rooms/castle/Room_15.tscn").instantiate())
	grid[0].push_back(load("res://Floor2/scenes/Rooms/castle/Room_E05.tscn").instantiate())
	grid[1].push_back(load("res://Floor2/scenes/Rooms/castle/Room_15.tscn").instantiate())
	
	for row in range(0, grid_h):
		for col in range(0, grid_w):
			grid[row][col].position = Vector2(room_w * col, room_h * row)
			add_child.call_deferred(grid[row][col])
	for col in range(0, grid_w):
		borders["sky"].push_back(load("res://Floor2/scenes/Rooms/castle/Room_15.tscn").instantiate())
		borders["sky"][borders["sky"].size()-1].position = Vector2(room_w * (borders["sky"].size()-1), -1 * room_h)
		add_child.call_deferred(borders["sky"][col])
		borders["base"].push_back(load("res://Floor2/scenes/Rooms/castle/Room_15.tscn").instantiate())
		borders["base"][borders["base"].size()-1].position = Vector2(room_w * (borders["sky"].size()-1), grid.size() * room_h)
		add_child.call_deferred(borders["base"][col])
	return [Vector2(room_w * (grid[0].size()-1)+240, room_h * (grid.size()-1)), Vector2(0, start_vertical * room_h + 40)]
