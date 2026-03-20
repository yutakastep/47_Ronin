extends Area2D
@onready var spawn_point = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	print("Respawn Trigger touched by", body.name)
	if(body.is_in_group("Player")):
		print("Supposed to set")
		GameEvents.platform_death_spawn_point = spawn_point.global_position
	else:
		print("Respawn Trigger Not Working")
