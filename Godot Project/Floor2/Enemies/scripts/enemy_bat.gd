class_name EnemyBat extends Floor2Enemies

@onready var state = "flying"
@onready var speed = 40
@onready var gravity = 0
@onready var knockback_velocity = 0


var spawn_position : Vector2
var player : CharacterBody2D
var direction = Vector2.ZERO

func _ready() -> void:
	#this line of code messes up the enemy trigger logic, as it overrides the global_position after it is set by the enemy trigger
	#global_position = spawn_position
	pass

func _process(delta: float) -> void:
	if !dying:
		match state:
			"flying":
				if !is_instance_valid(player):
					return
				elif !knocked_back:
					flying(player.global_position)
					if velocity.x > 0:
						$AnimatedSprite2D.flip_h = true
						$CollisionShape2D.scale.x = -1
						$RoninDetection.scale.x = -1
						$HitDetection.scale.x = -1
						$HitBox.scale.x = -1
					elif velocity.x < 0:
						$AnimatedSprite2D.flip_h = false
						$CollisionShape2D.scale.x = 1
						$RoninDetection.scale.x = 1
						$HitDetection.scale.x = 1
						$HitBox.scale.x = 1
				$AnimatedSprite2D.play("flying")
			"stinging":
				set_hitbox($AnimatedSprite2D.frame in [3, 4, 5])
				$AnimatedSprite2D.play("sting")
			
func _physics_process(delta):
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
			if state == "flying_pending":
				state = "flying"
	elif !dying and state == "flying":
		velocity = ((direction*speed) - velocity) * delta
	else:
		velocity.x = 0
	move_and_slide()

func flying(target):
	direction = (target - global_position)

func set_hitbox(on):
	$HitBox.monitoring = on
	$HitBox.monitorable = on
	$HitBox.visible = on

func _on_area_2d_body_entered(body: Node2D) -> void:
	state = "waiting"
	near_player = true
	$StingTimer.start(.15)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	near_player = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == "stinging":
		if near_player:
			state = "waiting"
			$StingTimer.start(.15)
		else:
			if knocked_back:
				state = "flying_pending"
			else:
				state = "flying"


func _on_sting_timer_timeout() -> void:
	$StingTimer.stop()
	if state == "waiting":
		state = "stinging"

func _on_hit_detection_area_entered(area: Area2D) -> void:
	print("enemy hit")
	$Flash.play("hit")
	
	knockback_velocity = -100 if direction.x > 0 else 100
	knocked_back = true
	
	# take_damage declared in base_enemy_floor1, takes damage amount as argument
	if take_damage(1):
		dying = true
		$AnimatedSprite2D.animation = "flying"
		$AnimatedSprite2D.frame = 2
		gravity = 200
		$StingTimer.start(.5)
		await $StingTimer.timeout
		death()
		
