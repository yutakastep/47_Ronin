extends CanvasLayer

signal shown
signal hidden

@onready var button_save = $Control/VBoxContainer/Button_Save
@onready var button_load = $Control/VBoxContainer/Button_Load
@onready var button_quit = $Control/VBoxContainer/Button_Quit
@onready var item_description = $Control/ItemDescription

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
	shown.emit()
	PlayerHud.visible = false
	# button_save.grab_focus()
	# need above for controller, currently not implementing

# if paused is false hide pause menu
func hide_pause_menu():
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()
	PlayerHud.visible = true



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
	
# function to update item description
func update_item_description(new_text: String):
	item_description.text = new_text
