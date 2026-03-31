extends Node2D



@onready var button_start = $CanvasLayer/Control/ButtonStart
@onready var button_exit = $CanvasLayer/Control/ButtonExit
@onready var button_credit = $CanvasLayer/Control/ButtonCredit
@onready var button_intro = $CanvasLayer/Control/ButtonIntro

func _ready():
	
	set_title_screen()
	go_to_credits()
	go_to_intro()
	close_title_screen()
	

func set_title_screen():
	button_start.pressed.connect(start_game)
	pass

func start_game():
	get_tree().change_scene_to_file("res://Floor1/scenes/floor1.tscn")

func go_to_intro():
	button_intro.pressed.connect(intro)
	
func intro():
	get_tree().change_scene_to_file("res://TitleScreen/intro.tscn")

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
