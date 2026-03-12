extends Node2D
@onready var kunai = load("res://misc/scenes/kunai.tscn")
@onready var ronins = load_ronin("res://Ronins/scenes/")

var ronin_spawn = Vector2(10, 170)

func _ready():
	var ronin = load(ronins.pick_random()).instantiate()
	var camera = Camera2D.new()
	camera.make_current()
	ronin.spawn_position = ronin_spawn
	ronin.add_child(camera)
	add_child.call_deferred(ronin)

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
