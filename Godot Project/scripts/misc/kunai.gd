extends CharacterBody2D

@export var speed = -300

var dir : float
var up : bool
var spwnPos : Vector2

func _ready() -> void:
	global_position = spwnPos
	rotation_degrees = 90 if up else 0
	
func _physics_process(delta: float) -> void:
	if up:
		position.y += speed * delta * dir
	else:
		position.x += speed * delta * dir
	
