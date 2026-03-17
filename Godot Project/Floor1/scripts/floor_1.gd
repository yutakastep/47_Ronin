extends Node2D
@onready var kunai = load("res://misc/scenes/kunai.tscn")
@onready var ronins = load_ronin("res://Ronins/scenes/")
@onready var dimensions = get_node("RoomManager").room_generation()

var ronin_spawn = Vector2(0, 15)
var enemy_spawn = Vector2(300, 170)

var enemies = []

var current_ronin : CharacterBody2D

func _ready():
	ronin_spawn = dimensions[1]
	spawn_ronin()
	
func _on_ronin_death():
	ronin_spawn = current_ronin.global_position
	spawn_ronin()
	GameEvents.ronin_death.emit(current_ronin)
	
func spawn_ronin():
	current_ronin  = PlayerManager.spawn_player(self, ronin_spawn)
	current_ronin.tree_exiting.connect(_on_ronin_death)
	var camera = Camera2D.new()
	camera.offset = Vector2(0, -20)
	camera.limit_left = -240
	camera.limit_right = dimensions[0].x
	camera.make_current()
	#print("Ronin Spawn? ", dimensions[1])
	current_ronin.speed = 200
	current_ronin.jump_speed = -250
	current_ronin.add_child(camera)

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
	ronin_spawn = current_ronin.global_position
	instance.spwnPos = ronin_spawn
	if up:
		var x = ronin_spawn.x - 4 if direction else ronin_spawn.x + 5
		instance.spwnPos = Vector2(x, ronin_spawn.y - 2 + combo_end - 1)
		await get_tree().create_timer(0.2).timeout
		
	elif combo_end > 0:
		instance.spwnPos = Vector2(ronin_spawn.x, ronin_spawn.y - 2 + combo_end - 1)
		if combo_end > 1:
			await get_tree().create_timer(0.2).timeout
			throw(false, direction, combo_end-2)
		
	add_child.call_deferred(instance)
