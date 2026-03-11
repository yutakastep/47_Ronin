extends CharacterBody2D

@onready var state = "walking"
@export var speed = 20
@export var gravity = 500

var spawn_position : Vector2
var player : CharacterBody2D

func _ready() -> void:
	global_position = spawn_position

func _process(delta: float) -> void:
	match state:
		"walking":
			walking(player.global_position, delta)
			if velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("walking")
			elif velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walking")
		"attacking":
			pass

func walking(target, delta):
	var direction = (target.x - global_position.x)
	velocity.x = ((direction*speed) - velocity.x) * delta * 2.5
	move_and_slide()
