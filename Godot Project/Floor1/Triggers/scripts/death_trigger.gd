extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Trigger touched by", body.name)
	if(body.is_in_group("Player")):
		print("Supposed to Kill")
		body.global_position = GameEvents.platform_death_spawn_point
		body.death()
		emit_signal("body_exited", body)
	else:
		print("Didn't Kill Player")
	#set_deferred("monitoring", false)
