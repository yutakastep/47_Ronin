extends CharacterBody2D

@export var speed = -300

var direction : Vector2
var up : bool
var spwnPos : Vector2

func _ready() -> void:
	global_position = spwnPos
	
func _physics_process(delta: float) -> void:
		position.x += speed * delta * direction.x * -1

func _on_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
