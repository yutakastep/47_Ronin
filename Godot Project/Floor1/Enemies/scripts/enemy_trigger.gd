extends Area2D
@export var enemy_scene : PackedScene
@onready var spawn_point = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	print("Trigger touched by", body.name)
	if(body.is_in_group("Player") and enemy_scene):
		print(spawn_point.global_position)
		GameEvents.spawn_enemy.emit(enemy_scene, spawn_point)
	else:
		print("No Enemy Spawn")
	set_deferred("monitoring", false)
