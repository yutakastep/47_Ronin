extends CanvasLayer

@onready var ronin_label = $RoninNumber
@onready var coins_label = $Coins

func _ready():
	update_ronin(PlayerManager.ronin_index)
	update_coins(PlayerManager.coins)

func update_ronin(index):
	ronin_label.text = "%d" % index

func update_coins(value):
	coins_label.text = "Coins: %d" % value
