extends Node2D



@onready var button_start = $CanvasLayer/Control/ButtonStart
@onready var button_exit = $CanvasLayer/Control/ButtonExit
@onready var button_credit = $CanvasLayer/Control/ButtonCredit

func _ready():
	
	set_title_screen()
	go_to_credits()
	close_title_screen()
	
	pass

func set_title_screen():
	button_start.pressed.connect(start_game)
	pass

func start_game():
	# TODO: Insert code here to load the first floor or homebase
	# TODO: Project settings > application > run > main scene > set to title scene
	pass

func go_to_credits():
	button_credit.pressed.connect(credits)
	pass

func credits():
	get_tree().change_scene_to_file("res://TitleScreen/credit_scene.tscn")

func close_title_screen():
	button_exit.pressed.connect(close_game)

func close_game():
	get_tree().quit()
	pass
