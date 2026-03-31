extends Node2D

func _ready():
	pass

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TitleScreen/title_scene.tscn")
