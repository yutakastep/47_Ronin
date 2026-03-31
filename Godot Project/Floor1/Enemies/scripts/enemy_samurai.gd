class_name EnemySamurai extends Floor1Enemies

@onready var state = "walking"
@onready var speed = 20
@onready var gravity = 500
@onready var knockback_velocity = 0


var spawn_position : Vector2
var player : CharacterBody2D
var direction = Vector2.ZERO

var near_player = false
var knocked_back = false

func _ready() -> void:
	#this line of code messes up the enemy trigger logic, as it overrides the global_position after it is set by the enemy trigger
	#global_position = spawn_position
	pass

func _process(delta: float) -> void:
	match state:
		"walking":
			if !is_instance_valid(player):
				return
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
	#print(global_position)
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
		velocity.x = ((direction.x*speed) - velocity.x) * delta * .75
	else:
		velocity.x = 0
	move_and_slide()

func walking(target, delta):
	direction.x = (target.x - global_position.x)

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
	
	knockback_velocity = -100 if direction.x > 0 else 100
	knocked_back = true
	
	# take_damage declared in base_enemy_floor1, takes damage amount as argument
	take_damage(1)
