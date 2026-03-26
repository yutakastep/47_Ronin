extends Node2D

var near = ""

func _ready() -> void:
	$Background/Tengu/Tengu.animation = "looking"

func _process(delta: float) -> void:
	$Background/Tengu/Tengu.frame = 0 if $Background/HomebaseRonin.global_position.x > $Background/Tengu/Tengu.global_position.x else 1
	if Input.is_action_just_pressed("interact"):
		print(near)
		match near:
			"gacha":
				$Gacha.visible = true
				$Background/HomebaseRonin.moveable = false
				near = "in gacha"
			"in gacha":
				$Gacha.spin()
			"door":
				SceneLoader.change_scene("res://Floor1/scenes/floor1.tscn")

func _input(event):
	if near != "in gacha":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collide_with_areas = true
		var results = space.intersect_point(query)
		for result in results:
			if result.collider == $ExitGachaArea:
				exit_gacha()

func _on_gacha_play_area_entered(area: Area2D) -> void:
	near = "gacha"
	
func _on_gacha_play_area_exited(area: Area2D) -> void:
	near = ""

func _on_leave_area_entered(area: Area2D) -> void:
	near = "door"

func _on_leave_area_exited(area: Area2D) -> void:
	near = ""

func exit_gacha():
	near = "gacha"
	$Gacha.visible = false
	$Background/HomebaseRonin.moveable = true
