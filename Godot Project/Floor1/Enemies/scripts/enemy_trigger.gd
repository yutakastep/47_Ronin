extends Area2D
@export var enemy_scene : PackedScene
@onready var spawn_point = $Marker2D

func spawn_enemy(player: CharacterBody2D):
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.player = player
		enemy.global_position = spawn_point.global_position
		get_tree().current_scene.add_child(enemy)
		set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	print("Trigger touched by", body.name)
	if(body.is_in_group("Player")):
		spawn_enemy(body)
