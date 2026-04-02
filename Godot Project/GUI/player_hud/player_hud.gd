extends CanvasLayer

@onready var ronin_label = $Label

func _ready():
	update_label(PlayerManager.ronin_index)
	PlayerManager.ronin_change.connect(update_label)

func update_label(index):
	ronin_label.text = "%d" % index
