extends Node2D
@onready var normal_rooms = load_rooms("res://Floor1/scenes/Rooms/Normal/")

var rng = RandomNumberGenerator.new()

func room_generation() -> Vector2:
	rng.randomize()
	var rooms = []
	var room_w = 480
	var room_h = 240
	rooms.push_back(load("res://Floor1/scenes/Rooms/Room_Start.tscn").instantiate())
	add_child.call_deferred(rooms[0])
	for i in range(1, rng.randi_range(3, 7)):
		rooms.push_back(load(normal_rooms.pick_random()).instantiate())
		rooms[i].position.x = room_w * i
		add_child.call_deferred(rooms[i])
	rooms.push_back(load("res://Floor1/scenes/Rooms/Room_End.tscn").instantiate())
	rooms[rooms.size()-1].position.x = room_w * (rooms.size()-1)
	add_child.call_deferred(rooms[rooms.size()-1])
	return Vector2(room_w * (rooms.size()-1)+240, room_h)

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
