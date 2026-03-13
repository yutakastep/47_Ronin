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
	global_position = spawn_position

func _process(delta: float) -> void:
	match state:
		"walking":
			if !knocked_back:
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
			$HitBox.monitoring = true
			$HitBox.monitorable = true
			$HitBox.visible = true
			$AnimatedSprite2D.play("attack")
			
func _physics_process(delta):

	# Add gravity every frame
	velocity.y += gravity * delta
	
	if knocked_back:
		print(velocity.x)
		velocity.x = knockback_velocity
		if knockback_velocity < 0:
			knockback_velocity += 2
		else:
			knockback_velocity -= 2
		
		if -2 < knockback_velocity && knockback_velocity < 2:
			knocked_back = false
			velocity.x = 0
			if state == "walking_pending":
				state = "walking"
	elif state == "walking":
		velocity.x = ((direction*speed) - velocity.x) * delta * .75
	move_and_slide()

func walking(target, delta):
	direction = (target.x - global_position.x)

func _on_area_2d_body_entered(body: Node2D) -> void:
	state = "waiting"
	near_player = true
	$AttackTimer.start(.15)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	near_player = false


func _on_animated_sprite_2d_animation_finished() -> void:
	$HitBox.monitoring = false
	$HitBox.monitorable = false
	$HitBox.visible = false
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
	health -= 1
	if(health <= 0):
		queue_free()
	knockback_velocity = -60 if direction > 0 else 60
	knocked_back = true
