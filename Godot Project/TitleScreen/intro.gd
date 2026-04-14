extends Node2D

func _ready():
	PlayerHud.visible = false

func _on_button_pressed() -> void:
	PlayerHud.visible = true
	get_tree().change_scene_to_file("res://TitleScreen/title_scene.tscn")
