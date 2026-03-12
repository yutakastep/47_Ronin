extends CharacterBody2D

@onready var state = "walking"
@export var speed = 20
@export var gravity = 500

var spawn_position : Vector2
var player : CharacterBody2D

var near_player = false

func _process(delta: float) -> void:
	match state:
		"walking":
			walking(player.global_position, delta)
			if velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$Area2D.scale.x = -1
				$AnimatedSprite2D.play("walking")
			elif velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$Area2D.scale.x = 1
				$AnimatedSprite2D.play("walking")
		"attacking":
			$AnimatedSprite2D.play("attack")

func walking(target, delta):
	var direction = (target.x - global_position.x)
	velocity.x = ((direction*speed) - velocity.x) * delta * 2.5
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	state = "waiting"
	near_player = true
	$AttackTimer.start(.15)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	near_player = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == "attacking":
		if near_player:
			state = "waiting"
			$AttackTimer.start(.15)
		else:
			state = "walking"


func _on_attack_timer_timeout() -> void:
	$AttackTimer.stop()
	if state == "waiting":
		state = "attacking"
