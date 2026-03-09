extends Node

# universal path for save data
const SAVE_PATH = "user://"

#signals for any time we need to indicate these actions happened
#signal game_loaded
signal game_saved

# save current data in dictionary, key-value pair
var current_save : Dictionary = {
	scene_path = "",
	# player key stores hp, position
	# not using vectors bc we're serializing data as a json format
	# translate data into a string, human-readable data
	player = {
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0
	},
	ronin_number = "",
	items = [],
	# variables to persist among levels (switch flipped, chest opened, etc.)
	persistence = [],
	quests = [] # might not be used
}

#func save_game():
#	update_player_data()
#	update_scene_path()
#	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
#	var save_json = JSON.stringify(current_save) # will convert dictionary above into json string
#	file.store_line(save_json)
#	game_saved.emit() # tell everything the game was saved
#	#print("save_game")
#	pass
#	
#func load_game():
#	#print("load_game")
#	pass

# func to help gather data

#func update_player_data():
#	# TODO: Create Player Manager (one player manager, change type of ronin through there)
#	var p : Player = PlayerManager.player
#	current_save.player.hp = p.hp
#	current_save.player.max_hp = p.max_hp
#	current_save.player.pos_x = p.global_position.x
#	current_save.player.pos_y = p.global_position.y

#func update_scene_path():
#	var p : String = ""  #create string to path where we're saving
#	for c in get_tree().root.get_children():
#		if c is Level:
#			p = c.scene_file_path
#	current_save.scene_path = p
