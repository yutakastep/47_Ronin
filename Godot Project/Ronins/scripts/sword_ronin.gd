class_name SwordRonin extends BaseRonin

enum BodyOption {SWORD, SPEAR, KUNAI}
enum ColorOption {RED, BLUE, BROWN, GREEN, PURPLE}
enum HeadOption {HAT, HAIR, CHONMAGE}

@export var body: BodyOption = BodyOption.SWORD :
	set(value):
		body = value
		if is_node_ready():
			apply_variant()

@export var head: HeadOption = HeadOption.HAT :
	set(value):
		head = value
		if is_node_ready():
			apply_variant()

@export var color: ColorOption = ColorOption.PURPLE :
	set(value):
		color = value
		if is_node_ready():
			apply_variant()

func apply_variant():
	var body_map = {
		BodyOption.SWORD: "Sword",
		BodyOption.SPEAR: "Spear",
		BodyOption.KUNAI: "Kunai"
	}
	
	var color_map = {
		ColorOption.RED: "Red",
		ColorOption.BLUE: "Blue",
		ColorOption.BROWN: "Brown",
		ColorOption.GREEN: "Green",
		ColorOption.PURPLE: "Purple"
	}
	
	var head_map = {
		HeadOption.HAT: "Hat",
		HeadOption.HAIR: "Hair",
		HeadOption.CHONMAGE: "Chonmage"
	}
	
	var base_path = "res://Ronins/sprites/%s/%s/%s/" % [body_map[body], head_map[head], color_map[color]]
	
	var sheet_map = {
		"breathing":   load(base_path + "breathing.png"),
		"walking":   load(base_path + "walking.png"),
		"attack_one": load(base_path + "attack.png"),
		"attack_two": load(base_path + "attack.png"),
		"attack_three": load(base_path + "attack.png"),  
		"attack_up": load(base_path + "up_attack.png"),
		"jump":   load(base_path + "jump.png"),
		"sheath":   load(base_path + "attack.png"),
		"death":  load(base_path + "death.png"),
	}
	
	var frames = $AnimatedSprite2D.sprite_frames
	for anim_name in frames.get_animation_names():
		for i in frames.get_frame_count(anim_name):
			var atlas = frames.get_frame_texture(anim_name, i)
			if atlas == null:
				continue
			if not atlas is AtlasTexture:
				continue
			atlas.atlas = sheet_map.get(anim_name)

func _ready() -> void:
	PlayerManager.player = self
	global_position = spawn_position
	apply_variant()

func _process(delta: float) -> void:
	if !dying and !sheathing:
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
		elif jumping:
			if velocity.y >= -200:
				$AnimatedSprite2D.frame = 0
			if velocity.y >= -90:
				$AnimatedSprite2D.frame = 1
			if velocity.y >= 90:
				$AnimatedSprite2D.frame = 2
			if !was_on_floor and is_on_floor():
				curr_jump = 0
				jumping = false
		elif !knocked_back and attack_index == 0:
			if is_on_floor() and Input.is_action_just_pressed("ui_down"):
				set_collision_mask_value(5, false)
				await get_tree().create_timer(0.3).timeout
				set_collision_mask_value(5, true)
			if Input.is_action_just_pressed("space"):
				$AnimatedSprite2D.animation = "jump"
				$AnimatedSprite2D.frame = 0
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
	was_on_floor = is_on_floor()
	

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
	
	elif !dying and !attacking && $ComboTimer.is_stopped():
		velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	elif !dying and !jumping && !sheathing:
		velocity.x = 0
	move_and_slide()

	# Only allow jumping up to cap
	if !dying and Input.is_action_just_pressed("space") and curr_jump < jump_cap:
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
		knockback_velocity = 60 if area.get_parent().direction.x > 0 else -60
		knocked_back = true
		
		# take_damage declared in base_ronin, takes damage amount as argument
		if take_damage(1) and !dying:
			dying = true
			$AnimatedSprite2D.play("death")
			await $AnimatedSprite2D.animation_finished
			death()
