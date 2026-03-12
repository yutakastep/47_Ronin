extends Node2D
@onready var kunai = load("res://misc/scenes/kunai.tscn")
@onready var ronins = load_ronin("res://Ronins/scenes/")
@onready var normal_rooms = load_rooms("res://Floor1/scenes/Rooms/Normal/")

var ronin_spawn = Vector2(0, 10)
var rng = RandomNumberGenerator.new()

func _ready():
	room_generation()
	var ronin = load(ronins.pick_random()).instantiate()
	var camera = Camera2D.new()
	camera.offset = Vector2(0, -20)
	camera.make_current()
	ronin.spawn_position = ronin_spawn
	ronin.speed = 200
	ronin.add_child(camera)
	add_child.call_deferred(ronin)
	
func room_generation():
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

func load_ronin(path: String) -> Array:
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

func throw(up, direction, combo_end):
	var instance = kunai.instantiate()
	instance.up = up
	instance.dir = 1 if direction || up else -1
	instance.spwnPos = $KunaiRonin.global_position
	if up:
		var x = $KunaiRonin.global_position.x - 4 if direction else $KunaiRonin.global_position.x + 5
		instance.spwnPos = Vector2(x, $KunaiRonin.global_position.y - 2 + combo_end - 1)
		await get_tree().create_timer(0.2).timeout
		
	elif combo_end > 0:
		instance.spwnPos = Vector2($KunaiRonin.global_position.x, $KunaiRonin.global_position.y - 2 + combo_end - 1)
		if combo_end > 1:
			await get_tree().create_timer(0.2).timeout
			throw(false, direction, combo_end-2)
		
	add_child.call_deferred(instance)
