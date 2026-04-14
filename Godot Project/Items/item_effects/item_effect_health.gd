class_name ItemEffectHealth extends ItemEffect
# extend any item effect and duplicate this format

@export var health_inc_amt: int = 3
@export var sound: AudioStream

func use():
	# change functionality to whatever we need
	PlayerManager.player.increase_health(health_inc_amt)
	# TODO: play sound?

# the apple does this
