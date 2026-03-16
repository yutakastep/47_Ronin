extends Node2D
@onready var player = PlayerManager.player

var enemies = []

func _ready():
	GameEvents.spawn_enemy.connect(_on_spawn_enemy)
	GameEvents.ronin_death.connect(_on_ronin_death)

func _on_spawn_enemy(enemy_scene, spawn_point):
	var enemy = enemy_scene.instantiate()
	enemy.player = PlayerManager.player
	enemy.global_position = spawn_point.global_position
	add_child.call_deferred(enemy)
	set_deferred("monitoring", false)
	enemies.push_back(enemy)
	print(enemy.global_position)
	print(PlayerManager.player.global_position)

func _on_ronin_death():
	print("Changing Enemy's Ronin")
	for enemy in enemies:
		enemy.player = PlayerManager.player
