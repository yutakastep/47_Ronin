extends Node

#const PLAYER = preload("res://Ronins/scripts/kunai_ronin.gd")
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

var player
var unlocked_ronins = []
var locked_ronins = []
var run_ronins = []
var alive_ronins = []
var rng = RandomNumberGenerator.new()

var max_ronin: int = 1
var ronin_index: int = 1
var coins: int = 1
signal ronin_change(index)
signal coins_changed(value)

func _ready():
	unlocked_ronins = load_ronins("res://Ronins/scenes/Unlocked Ronin")
	locked_ronins = load_ronins("res://Ronins/scenes/Locked Ronin")
	rng.randomize()
 
func spawn_player(parent, spawn_position):
	
		var scene = load(run_ronins.pop_at(randi() % run_ronins.size())) if run_ronins.size() > 1 else load(run_ronins[0])
		print(scene)
		player = scene.instantiate()
		player.name = "Player"
		player.spawn_position = spawn_position
		player.add_to_group("Player")
		player.died.connect(_on_player_died)
		parent.add_child.call_deferred(player)
		return player

func load_ronins(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				files.append(path.path_join(file_name))
			file_name = dir.get_next()
	return files

func load_ronins_for_run() -> void:
	run_ronins = unlocked_ronins;

func _on_player_died(_ronin):
	ronin_index -= 1
	ronin_change.emit(ronin_index)
	if(ronin_index == 0):
		reset_ronin()
		GameEvents.floor_count = 0
		GameEvents.next_floor_level = 0
		get_tree().change_scene_to_file("res://Homebase/scenes/homebase.tscn")
		
func add_ronin():
	ronin_index += 1
	max_ronin = ronin_index
	ronin_change.emit(ronin_index)

func reset_ronin():
	ronin_index = max_ronin
	ronin_change.emit(ronin_index)
	
func add_coins(amount: int) -> void:
	coins += amount
	print("coins added")
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	
	coins -= amount
	coins_changed.emit(coins)
	return true
