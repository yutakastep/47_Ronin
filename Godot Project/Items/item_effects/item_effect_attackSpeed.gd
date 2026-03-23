class_name ItemEffectAttackSpeed extends ItemEffect
# extend any item effect and duplicate this format

@export var attackSpeed_inc_amt: float = 1.5
@export var sound: AudioStream

func use():
	# change functionality to whatever we need
	PlayerManager.player.increase_attackSpeed(attackSpeed_inc_amt)
	# TODO: play sound?

# the sake does this
