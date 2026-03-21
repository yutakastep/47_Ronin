class_name SwordRonin extends CharacterBody2D

@export var speed = 60
@export var jump_speed = -200
@export var gravity = 500
var combo_count: int = 0
@onready var combo_timer: Timer = $ComboTimer
@onready var hitboxes = [$Hitboxes/AttackOne, $Hitboxes/AttackTwo, $Hitboxes/AttackThree, $Hitboxes/AttackUp] 
@onready var knockback_velocity = 0

var spawn_position : Vector2
var attack_index = 0
var sheathing = false
var timedout = false
var attacking = false
var jumping = false
var jump_cap = 2
var curr_jump = 0
var knocked_back = false

var health = 3

func _ready() -> void:
	PlayerManager.player = self
	global_position = spawn_position

func _process(delta: float) -> void:
	if !sheathing:
		if Input.is_action_just_pressed("interact"):
			GameEvents.interact.emit()
		if Input.is_action_just_pressed("noclip"):
			gravity = 0
			get_node("CollisionShape2D").disabled = true
		
		if Input.is_action_just_pressed("attack"):
			if Input.is_action_pressed("ui_up"):
				attack(4, "attack_up")
			match attack_index:
				0:
					attack(1, "attack_one")
				1:
					if !attacking:
						attack(2, "attack_two")
				2:
					if !attacking:
						attack(3, "attack_three")
						
		if attacking:
			match attack_index:
				1:
					set_hitbox($Hitboxes/AttackOne, $AnimatedSprite2D.frame in [6, 7, 8])
				2:
					set_hitbox($Hitboxes/AttackTwo, $AnimatedSprite2D.frame in [0, 1, 2])
				3:
					set_hitbox($Hitboxes/AttackThree, $AnimatedSprite2D.frame in [2, 3, 4])
				4:
					set_hitbox($Hitboxes/AttackUp, $AnimatedSprite2D.frame in [5, 6, 7])
					
		elif !jumping and !knocked_back and attack_index == 0:
			if is_on_floor() and Input.is_action_just_pressed("ui_down"):
				set_collision_mask_value(5, false)
				await get_tree().create_timer(0.3).timeout
				set_collision_mask_value(5, true)
			if Input.is_action_just_pressed("space"):
				$AnimatedSprite2D.play("jump")
				jumping = true
			elif velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("walking")
				$Hitboxes.scale.x = -1
			elif velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walking")
				$Hitboxes.scale.x = 1
			else:
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
	
	elif !attacking && $ComboTimer.is_stopped():
		velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	elif !jumping && !sheathing:
		velocity.x = 0
	move_and_slide()
	if is_on_floor():
		curr_jump = 0

	# Only allow jumping up to cap
	if Input.is_action_just_pressed("space") and curr_jump < jump_cap:
		curr_jump = curr_jump + 1
		velocity.y = jump_speed

func attack(attack_indx, attack) -> void:
	if(1 < attack_indx && attack_indx < 4 && jumping):
		return
	$AnimatedSprite2D.play(attack)
	attack_index = attack_indx
	attacking = true
	$ComboTimer.stop()

func set_hitbox(hitbox, on):
	hitbox.monitoring = on
	hitbox.monitorable = on
	hitbox.visible = on

func sheath() -> void:
	$AnimatedSprite2D.play("sheath")
	sheathing = true
	attack_index = 0
	timedout = false;
	attacking = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if sheathing:
		sheathing = false
	elif attack_index == 3:
		sheath()
	elif attack_index == 4:
		if jumping:
			jumping = false
		sheath()
	elif attack_index > 0:
		if jumping:
			jumping = false
			$ComboTimer.start(.1)
			sheath()
			return
		$ComboTimer.start(.2)
		attacking = false
	elif jumping:
		jumping = false

func _on_combo_timer_timeout() -> void:
	sheath()
	$ComboTimer.stop()

func _on_hit_detection_area_entered(area: Area2D) -> void:
	if area.get_parent() is CharacterBody2D:
		print("sword ronin hit")
		$Flash.play("hit")
		knockback_velocity = 100 if area.get_parent().direction > 0 else -100
		knocked_back = true
		health -= 1
		if health <= 0:
			queue_free()
		
# function to increase speed for item pickups
# might need a global item pickup manager for all the ronin
# if we're being lazy honestly we could just copy paste item effects for all the ronin
# unless items would have different effects for different ronin
func increase_speed(spd_inc_amount):
	print("hit")
	speed += spd_inc_amount
	print("increase speed by: ", spd_inc_amount)
