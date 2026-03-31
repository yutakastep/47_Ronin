@tool # want it to update as we add into world
class_name ItemPickup extends Node2D

@export var item_data : ItemData : set = _set_item_data

@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _ready():
	_update_texture()
	# check if in editor (anything before this will work in editor
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect(_on_body_entered)

#TODO: change to player once manager is set up
func _on_body_entered(body):
	if body.is_in_group("Player") and item_data:  # check for player collision layer 2
		if PlayerManager.INVENTORY_DATA.add_item(item_data) == true:
			item_picked_up()
			item_data.use()
	pass

# only called if there was room in inventory
func item_picked_up():
	area_2d.body_entered.disconnect(_on_body_entered)
	audio_stream_player_2d.play()
	visible = false
	await audio_stream_player_2d.finished
	queue_free()
	pass

func _set_item_data(value: ItemData):
	item_data = value
	_update_texture()
	pass

func _update_texture():
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
