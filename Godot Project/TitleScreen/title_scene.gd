extends Node2D

const START_LEVEL: String = "res://Floor1/scenes/floor1.tscn"

@onready var button_start = $CanvasLayer/Control/ButtonStart
@onready var button_exit = $CanvasLayer/Control/ButtonExit

func _ready():
	
	set_title_screen()
	close_title_screen()
	
	pass

func set_title_screen():
	button_start.pressed.connect(start_game)
	pass

func start_game():
	# TODO: Insert code here to load the first floor or homebase
	# TODO: Project settings > application > run > main scene > set to title scene
	pass

func close_title_screen():
	button_exit.pressed.connect(close_game)

func close_game():
	get_tree().quit()
	pass
