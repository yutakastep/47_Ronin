class_name BaseRonin extends CharacterBody2D

#created to consolidate any commonalities between all three of the ronin types
#mostly for simplifying powerup implementation functions
#can also be used for universal ronin functions

@export var speed: float = 60
@export var jump_speed: float = -200
@export var gravity: float = 500
@export var attack_speed: float = 1.0

@export var max_health: int = 3
var health: int

var spawn_position : Vector2

var attack_index = 0
var knockback_velocity = 0
var sheathing = false
var timedout = false
var attacking = false
var jumping = false
var jump_cap = 2
var curr_jump = 0
var knocked_back = false
var was_on_floor = true
var dying = false

signal died(ronin)
	
func _ready():
	health = max_health

func take_damage(amount: int) -> bool:
	health -= amount
	if health <= 0:
		return true
	return false

func death() -> void:
	died.emit(self)
	queue_free()

# function to increase speed for item pickups
# might need a global item pickup manager for all the ronin
# if we're being lazy honestly we could just copy paste item effects for all the ronin
# unless items would have different effects for different ronin
func increase_speed(spd_inc_amt) -> void:
	speed += spd_inc_amt
	print("increase speed by: ", spd_inc_amt)

func increase_jumpHeight(jumpHeight_inc_amt) -> void:
	gravity -= jumpHeight_inc_amt
	print("decrease gravity by:", jumpHeight_inc_amt)

func increase_attackSpeed(attackSpeed_inc_amt) -> void:
	attack_speed *= attackSpeed_inc_amt
	print("increase attack speed by: *", attackSpeed_inc_amt)

func increase_heath(health_inc_amt) -> void:
	max_health += health_inc_amt
	health += health_inc_amt
	print("increase health by: ", health_inc_amt)
