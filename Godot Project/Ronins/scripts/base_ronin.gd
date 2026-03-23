class_name BaseRonin extends CharacterBody2D

#created to consolidate any commonalities between all three of the ronin types
#mostly for simplifying powerup implementation functions
#can also be used for universal ronin functions

@export var speed = 60
@export var jump_speed = -200
@export var gravity = 500
@export var attack_speed: float = 1.0

# function to increase speed for item pickups
# might need a global item pickup manager for all the ronin
# if we're being lazy honestly we could just copy paste item effects for all the ronin
# unless items would have different effects for different ronin
func increase_speed(spd_inc_amt):
	speed += spd_inc_amt
	print("increase speed by: ", spd_inc_amt)

func increase_jumpHeight(jumpHeight_inc_amt):
	gravity -= jumpHeight_inc_amt
	print("decrease gravity by:", jumpHeight_inc_amt)

func increase_attackSpeed(attackSpeed_inc_amt):
	attack_speed *= attackSpeed_inc_amt
	print("increase attack speed by: *", attackSpeed_inc_amt)
