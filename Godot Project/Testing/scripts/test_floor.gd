extends Node2D

@onready var kunai = load("res://misc/scenes/kunai.tscn")
@onready var bullet = load("res://misc/scenes/bullet.tscn")
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
	var enemy = gunman.instantiate()
	enemy.spawn_position = enemy_spawn
	enemy.player = current_ronin
	add_child.call_deferred(enemy)
	enemy.tree_exiting.connect(_on_enemy_death)
	enemies.push_back(enemy)
	
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

func shoot(direction, position):
	var instance = bullet.instantiate()
	instance.direction.x = -1 if direction else 1
	instance.spwnPos = position
	add_child.call_deferred(instance)

func _on_ronin_death():
	ronin_spawn = current_ronin.global_position
	spawn_ronin()
	for enemy in enemies:
		if enemy:
			enemy.player = current_ronin
			
func _on_enemy_death():
	spawn_enemy()
