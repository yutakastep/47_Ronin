class_name Floor2Enemies extends CharacterBody2D

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
		
		var spacing: float = 12.0
		var start_offset: float = -((drop_count - 1) * spacing) / 2.0
		for i in range(drop_count):
			var drop: ItemPickup = PICKUP.instantiate()
			drop.item_data = drop_data.item
			
			var offset_x = start_offset + i * spacing
			drop.global_position = global_position + Vector2(offset_x, 0)
			
			get_parent().call_deferred("add_child", drop)
			
			var dir = sign(offset_x) if offset_x != 0 else randf_range(-1, 1)
			drop.velocity = Vector2(dir * randf_range(30, 50), 0)
	pass
