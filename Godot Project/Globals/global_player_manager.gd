extends Node

#const PLAYER = preload("res://Ronins/scripts/kunai_ronin.gd")
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

var player
var ronins = []
var rng = RandomNumberGenerator.new()

func _ready():
	ronins = load_ronins("res://Ronins/scenes/")
	rng.randomize()

func spawn_player(parent, spawn_position):
	var scene = load(ronins.pick_random())
	player = scene.instantiate()
	player.name = "Player"
	player.spawn_position = spawn_position
	player.add_to_group("Player")
	parent.add_child.call_deferred(player)
	return player

func load_ronins(path: String) -> Array:
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
