extends Node2D

@onready var kunai = load("res://misc/scenes/kunai.tscn")
@onready var samurai = load("res://Floor1/Enemies/scenes/enemy_samurai.tscn")

var ronin_spawn = Vector2(10, 170)
var enemy_spawn = Vector2(300, 170)

func _ready():
	var ronin = PlayerManager.spawn_player(self, ronin_spawn)
	
	var enemy = samurai.instantiate()
	enemy.spawn_position = enemy_spawn
	enemy.player = ronin
	add_child.call_deferred(enemy)

	
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
