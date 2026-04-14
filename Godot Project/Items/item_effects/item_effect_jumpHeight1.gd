class_name ItemEffectJumpHeight1 extends ItemEffect
# extend any item effect and duplicate this format

@export var jumpHeight_inc_amt: int = 50
@export var sound: AudioStream

func use():
	# change functionality to whatever we need
	PlayerManager.player.increase_jumpHeight(jumpHeight_inc_amt)
	# TODO: play sound?

# the turnip does this
