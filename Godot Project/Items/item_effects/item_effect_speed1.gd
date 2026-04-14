class_name ItemEffectSpeed1 extends ItemEffect
# extend any item effect and duplicate this format

@export var spd_inc_amt: int = 25
@export var sound: AudioStream

func use():
	# change functionality to whatever we need
	PlayerManager.player.increase_speed(spd_inc_amt)
	# TODO: play sound?

# the chicken does this
