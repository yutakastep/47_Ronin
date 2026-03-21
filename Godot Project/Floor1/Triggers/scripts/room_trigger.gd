extends Node2D

func _ready():
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exit)

func _on_body_entered(body: Node2D) -> void:
	print("Trigger touched by", body.name)
	if(body.is_in_group("Player")):
		GameEvents.interact.connect(_on_interact)
	else:
		print("Room Trigger Not Working")
		
func _on_body_exit(body: Node2D) -> void:
	print("Trigger left by", body.name)
	if(body.is_in_group("Player")):
		GameEvents.interact.disconnect(_on_interact)

func _on_interact():
	print("Room Trigger Interracted With")
	GameEvents.interact.disconnect(_on_interact)
	print(get_tree().reload_current_scene())
