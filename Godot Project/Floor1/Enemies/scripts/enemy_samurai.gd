extends CharacterBody2D

@onready var state = "walking"
@onready var speed = 20
@onready var gravity = 500
@onready var knockback_velocity = 0


var spawn_position : Vector2
var player : CharacterBody2D
var direction = 0
var health = 3

var near_player = false
var knocked_back = false

func _ready() -> void:
	#global_position = spawn_position
	pass

func _process(delta: float) -> void:
	match state:
		"walking":
			if !is_instance_valid(player):
				pass
			elif !knocked_back:
				walking(player.global_position, delta)
				if velocity.x < 0:
					$AnimatedSprite2D.flip_h = true
					$RoninDetection.scale.x = -1
					$HitBox.scale.x = -1
					$AnimatedSprite2D.play("walking")
				elif velocity.x > 0:
					$AnimatedSprite2D.flip_h = false
					$RoninDetection.scale.x = 1
					$HitBox.scale.x = 1
					$AnimatedSprite2D.play("walking")
		"attacking":
			set_hitbox(0 < $AnimatedSprite2D.frame and $AnimatedSprite2D.frame < 4)
			$AnimatedSprite2D.play("attack")
			
func _physics_process(delta):

	# Add gravity every frame
	velocity.y += gravity * delta
	
	if knocked_back:
		velocity.x = knockback_velocity
		if knockback_velocity < 0:
			knockback_velocity += 4
		else:
			knockback_velocity -= 4
		
		if -2 < knockback_velocity && knockback_velocity < 2:
			knocked_back = false
			velocity.x = 0
			if state == "walking_pending":
				state = "walking"
	elif state == "walking":
		velocity.x = ((direction*speed) - velocity.x) * delta * .75
	else:
		velocity.x = 0
	move_and_slide()
	#print(global_position)

func walking(target, delta):
	direction = (target.x - global_position.x)

func set_hitbox(on):
	$HitBox.monitoring = on
	$HitBox.monitorable = on
	$HitBox.visible = on

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
			if knocked_back:
				state = "walking_pending"
			else:
				state = "walking"


func _on_attack_timer_timeout() -> void:
	$AttackTimer.stop()
	if state == "waiting":
		state = "attacking"

func _on_hit_detection_area_entered(area: Area2D) -> void:
	print("enemy hit")
	$Flash.play("hit")
	health -= 1
	if(health <= 0):
		queue_free()
	knockback_velocity = -100 if direction > 0 else 100
	knocked_back = true
