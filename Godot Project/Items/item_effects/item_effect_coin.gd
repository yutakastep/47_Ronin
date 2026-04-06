class_name ItemEffectCoin extends ItemEffect
# extend any item effect and duplicate this format

@export var coin_number: int = 1
@export var sound: AudioStream

func use():
	# change functionality to whatever we need
	#print("coin effect triggered")
	PlayerManager.add_coins(coin_number)
	# TODO: play sound?

# the coin does this
