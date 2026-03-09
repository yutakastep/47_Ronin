extends Node2D

@onready var main = get_tree().get_root().get_node("TestFloor")
@onready var kunai = load("res://scenes/misc/kunai.tscn")


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
		
	main.add_child.call_deferred(instance)
