extends Node2D

@onready var ronins = load_ronins("res://Ronins/scenes/")
@onready var samurai = load("res://Floor1/Enemies/scenes/enemy_samurai.tscn")
@onready var wasp = load("res://Floor1/Enemies/scenes/enemy_wasp.tscn")
@onready var gunman = load("res://Floor1/Enemies/scenes/enemy_gunman.tscn")

var ronin_spawn = Vector2(10, 170)
var enemy_spawn = Vector2(100, 170)

var enemies = []

var current_ronin : CharacterBody2D

func _ready():
	spawn_ronin()
	spawn_enemy()

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
	
func spawn_ronin():
	current_ronin  = PlayerManager.spawn_player(self, ronin_spawn)
	current_ronin.tree_exiting.connect(_on_ronin_death)
	
func spawn_enemy():
	var enemy = samurai.instantiate()
	enemy.spawn_position = enemy_spawn
	enemy.player = current_ronin
	add_child.call_deferred(enemy)
	enemy.tree_exiting.connect(_on_enemy_death)
	enemies.push_back(enemy)

func _on_ronin_death():
	ronin_spawn = current_ronin.global_position
	spawn_ronin()
	for enemy in enemies:
		if enemy:
			enemy.player = current_ronin
			
func _on_enemy_death():
	await get_tree().create_timer(3).timeout
	spawn_enemy()
	pass
