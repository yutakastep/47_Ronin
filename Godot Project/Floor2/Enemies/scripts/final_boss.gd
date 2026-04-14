class_name FinalBoss extends BaseRonin

@onready var hitboxes = [$AttackOne, $AttackTwo, $AttackThree]

var player : CharacterBody2D
var direction = Vector2.ZERO
var state = "walkindg"
var near_front = false
var near_up = false

func _ready() -> void:
	speed = 30
	health = 10

func _process(delta: float) -> void:
	if !dying and !sheathing:		
		match state:
			"attack up":
				state = "attacking"
				attack(4, "attack_up")
			"attack front":
				state = "attacking"
				match attack_index:
					0:
						attack(1, "attack_one")
					1:
						attack(2, "attack_two")
					2:
						attack(3, "attack_three")
						
			"attacking":
				match attack_index:
					1:
						set_hitbox($AttackOne, $AnimatedSprite2D.frame in [6, 7, 8])
					2:
						set_hitbox($AttackTwo, $AnimatedSprite2D.frame in [0, 1, 2])
					3:
						set_hitbox($AttackThree, $AnimatedSprite2D.frame in [2, 3, 4])
					4:
						set_hitbox($AttackUp, $AnimatedSprite2D.frame in [5, 6, 7])
			"walking":
				walking()
				if velocity.x < 0:
					$AnimatedSprite2D.play("walking")
					$AnimatedSprite2D.flip_h = true
					$RoninDetectionFront.scale.x = -1
					for hitbox in hitboxes:
						hitbox.scale.x = -1
				elif velocity.x > 0:
					$AnimatedSprite2D.play("walking")
					$AnimatedSprite2D.flip_h = false
					$RoninDetectionFront.scale.x = 1
					for hitbox in hitboxes:
						hitbox.scale.x = 1
			"breathing":
				walking()
				$AnimatedSprite2D.play("breathing")

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
	
	elif !dying and state == "walking":
		velocity.x = ((direction.x*speed) - velocity.x) * delta
	else:
		velocity.x = 0
	move_and_slide()

func walking():
	direction.x = (player.global_position.x - global_position.x)
	state = "walking" if abs(direction.x) < 100 else "breathing"
	
func attack(attack_indx, attack) -> void:
	$AnimatedSprite2D.play(attack)
	attack_index = attack_indx

func set_hitbox(hitbox, on):
	hitbox.monitoring = on
	hitbox.monitorable = on
	hitbox.visible = on

func sheath() -> void:
	$AnimatedSprite2D.play("sheath")
	sheathing = true
	attack_index = 0
	timedout = false;
	wait_for_attack(.45)

func wait_for_attack(timing):
	state = "waiting"
	$AttackTimer.start(timing)
	
func _on_ronin_detection_front_body_entered(body: Node2D) -> void:
	near_front = true
	wait_for_attack(.2)

func _on_ronin_detection_front_body_exited(body: Node2D) -> void:
	near_front = false

func _on_ronin_detection_up_body_entered(body: Node2D) -> void:
	near_up = true
	wait_for_attack(.1)

func _on_ronin_detection_up_body_exited(body: Node2D) -> void:
	near_up = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if sheathing:
		sheathing = false
	elif attack_index == 3:
		sheath()
	elif attack_index == 4:
		print(near_up)
		sheath()
	elif attack_index > 0:
		wait_for_attack(.15)

func _on_combo_timer_timeout() -> void:
	if !near_front:
		sheath()
	$ComboTimer.stop()

func _on_attack_timer_timeout() -> void:
	$AttackTimer.stop()
	if near_front:
		state = "attack front"
	elif near_up:
		state = "attack up"
	else:
		if attack_index != 0:
			sheath()
		state = "breathing"

func _on_hit_detection_area_entered(area: Area2D) -> void:
	print("boss hit")
	$Flash.play("hit")
	
	knockback_velocity = -100 if direction.x > 0 else 100
	knocked_back = true

	# take_damage declared in base_enemy_floor1, takes damage amount as argument
	if take_damage(1):
		dying = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		death()
