class_name Floor1Enemies extends CharacterBody2D

# consolidates universal floor one enemy interactions
# mainly created so that they drop specifically level 1 items

const PICKUP = preload("res://Items/item_pickup/ItemPickup.tscn")
@export_category("Item Drops")
@export var drops: Array[ItemDropData]
# IMPORTANT NOTE: MUST SET ITEM ARRAY FOR EACH ENEMY SCENE IN INSPECTOR

@export_category("Health")
@export var max_health: int = 3
var health: int

var near_player = false
var knocked_back = false
var dying = false

signal died(enemy)

func _ready():
	health = max_health

func take_damage(amount: int) -> bool:
	health -= amount
	if health <= 0:
		return true
	return false

func death() -> void:
	died.emit(self)
	drop_items()
	queue_free()

func drop_items() -> void:
	if drops.is_empty():
		return
	for drop_data in drops:
		if drop_data == null or drop_data.item == null:
			continue
		var drop_count: int = drop_data.get_drop_count()
		for i in range(drop_count):
			var drop: ItemPickup = PICKUP.instantiate()
			drop.item_data = drop_data.item
			drop.global_position = global_position
			get_parent().call_deferred("add_child", drop)
	pass
