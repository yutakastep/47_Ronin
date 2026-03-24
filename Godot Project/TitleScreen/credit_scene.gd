extends Node2D

@onready var button_back = $CanvasLayer/Control/ButtonBack

func _ready():
	back_button_pressed()
	pass

func back_button_pressed():
	button_back.pressed.connect(back)

func back():
	get_tree().change_scene_to_file("res://TitleScreen/title_scene.tscn")
