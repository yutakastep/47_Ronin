extends CanvasLayer

@onready var button_save = $VBoxContainer/Button_Save
@onready var button_load = $VBoxContainer/Button_Load
@onready var button_quit = $VBoxContainer/Button_Quit
var is_paused : bool=false

func _ready():
	hide_pause_menu()
	#connect buttons
	button_save.pressed.connect( _on_save_pressed ) # when save pressed call save pressed func
	button_load.pressed.connect( _on_load_pressed )  # same but load
	button_quit.pressed.connect( _on_quit_pressed )
	pass # Replace with function body.

# activates when "pause" button is pressed (esc)
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

# if paused is true show pause menu
func show_pause_menu():
	get_tree().paused = true
	visible = true
	is_paused = true
	# button_save.grab_focus()
	# need above for controller, currently not implementing

# if paused is false hide pause menu
func hide_pause_menu():
	get_tree().paused = false
	visible = false
	is_paused = false



func _on_save_pressed():
	if is_paused == false:  # check if actually paused
		return
	SaveManager.save_game()
	hide_pause_menu()
	pass
	
func _on_load_pressed():
	if is_paused == false:  # check if actually paused
		return
	SaveManager.load_game()
	hide_pause_menu()
	pass
	
func _on_quit_pressed():
	if is_paused == false:  # check if actually paused
		return
	get_tree().quit()
	hide_pause_menu()
	pass
	
	
	
