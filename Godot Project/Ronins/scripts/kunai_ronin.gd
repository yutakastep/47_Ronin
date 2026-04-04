class_name KunaiRonin extends BaseRonin

@onready var kunai = load("res://misc/scenes/kunai.tscn")

# this is temporary, will change depending on if we need to make a character manager
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

enum BodyOption {SWORD, SPEAR, KUNAI}
enum ColorOption {RED, BLUE, BROWN, GREEN, PURPLE}
enum HeadOption {WRAP, HAIR, CHONMAGE}

@export var body: BodyOption = BodyOption.SWORD :
	set(value):
		body = value
		if is_node_ready():
			apply_variant()

@export var head: HeadOption = HeadOption.WRAP :
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
		HeadOption.WRAP: "Wrap",
		HeadOption.HAIR: "Hair",
		HeadOption.CHONMAGE: "Chonmage"
	}
	
	var base_path = "res://Ronins/sprites/%s/%s/%s/" % [body_map[body], head_map[head], color_map[color]]
	
	var sheet_map = {
		"breathing":   load(base_path + "breathing.png"),
		"walking":   load(base_path + "walking.png"),
		"attack_one": load(base_path + "attacking.png"),
		"attack_two": load(base_path + "attacking.png"),
		"attack_three": load(base_path + "attacking.png"),  
		"attack_up": load(base_path + "up-attack.png"),
		"jump":   load(base_path + "jump.png"),
		"sheath":   load(base_path + "attacking.png"),
		"realod": load(base_path + "attacking.png"),
		"death":  load(base_path + "death.png")
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
	#PlayerManager.player = self
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
				throw(true, $AnimatedSprite2D.flip_h, 0)

			match attack_index:
				0:
					attack(1, "attack_one")
					throw(false, $AnimatedSprite2D.flip_h, 0)
				1:
					if !attacking:
						attack(2, "attack_two")
						throw(false, $AnimatedSprite2D.flip_h,0)
				2:
					if !attacking:
						attack(3, "attack_three")
						throw(false, $AnimatedSprite2D.flip_h, 3)
		elif jumping and !attacking:
			if velocity.y >= -200:
				$AnimatedSprite2D.frame = 0
			if velocity.y >= -90:
				$AnimatedSprite2D.frame = 1
			if velocity.y >= 90:
				$AnimatedSprite2D.frame = 2
			if !was_on_floor and is_on_floor():
				curr_jump = 0
				jumping = false
		elif !attacking and !jumping and !knocked_back and attack_index == 0:
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
			elif velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walking")
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
	$AnimatedSprite2D.play(attack, attack_speed)
	attack_index = attack_indx
	attacking = true
	$ComboTimer.stop()

func throw(up, direction, combo_end):
	var instance = kunai.instantiate()
	instance.up = up
	instance.dir = 1 if direction || up else -1
	var ronin_spawn = global_position
	instance.spwnPos = ronin_spawn
	if up:
		var x = ronin_spawn.x - 4 if direction else ronin_spawn.x + 5
		instance.spwnPos = Vector2(x, ronin_spawn.y - 2 + combo_end - 1)
		await get_tree().create_timer(0.2).timeout
		
	elif combo_end > 0:
		instance.spwnPos = Vector2(ronin_spawn.x, ronin_spawn.y - 2 + combo_end - 1)
		if combo_end > 1:
			await get_tree().create_timer(0.2).timeout
			throw(false, direction, combo_end-2)
		
	get_parent().add_child.call_deferred(instance)

func sheath() -> void:
	$AnimatedSprite2D.play("sheath")
	sheathing = true
	attack_index = 0
	timedout = false;
	attacking = false

func reload() -> void:
	$AnimatedSprite2D.play("reload")
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

func _on_combo_timer_timeout() -> void:
	$ComboTimer.stop()
	if attack_index == 1 || attack_index == 4:
		reload()
		return
	sheath()

func _on_hit_detection_area_entered(area: Area2D) -> void:
	if area.get_parent() is CharacterBody2D:
		$Flash.play("hit")
		print("kunai ronin hit")
		knockback_velocity = 60 if area.get_parent().direction.x > 0 else -60
		knocked_back = true
		# take_damage declared in base_ronin, takes damage amount as argument
		if take_damage(1):
			dying = true
			$AnimatedSprite2D.play("death")
			await $AnimatedSprite2D.animation_finished
			death()
