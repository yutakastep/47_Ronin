class_name KunaiRonin extends BaseRonin

var combo_count: int = 0
@onready var combo_timer: Timer = $ComboTimer
@onready var parent = get_parent()
@onready var knockback_velocity = 0

# this is temporary, will change depending on if we need to make a character manager
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

var spawn_position : Vector2
var attack_index = 0
var sheathing = false
var timedout = false
var attacking = false
var jumping = false
var jump_cap = 2
var curr_jump = 0
var knocked_back = false
var was_on_floor = true

var health = 3

func _ready() -> void:
	#PlayerManager.player = self
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
				parent.throw(true, $AnimatedSprite2D.flip_h, 0)

			match attack_index:
				0:
					attack(1, "attack_one")
					parent.throw(false, $AnimatedSprite2D.flip_h, 0)
				1:
					if !attacking:
						attack(2, "attack_two")
						parent.throw(false, $AnimatedSprite2D.flip_h,0)
				2:
					if !attacking:
						attack(3, "attack_three")
						parent.throw(false, $AnimatedSprite2D.flip_h, 3)
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
	
	elif !attacking && $ComboTimer.is_stopped():
		velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	elif !jumping && !sheathing:
		velocity.x = 0
		
	move_and_slide()

	# Only allow jumping up to cap
	if Input.is_action_just_pressed("space") and curr_jump < jump_cap:
		curr_jump = curr_jump + 1
		velocity.y = jump_speed

func attack(attack_indx, attack) -> void:
	if(1 < attack_indx && attack_indx < 4 && jumping):
		return
	$AnimatedSprite2D.play(attack, attack_speed)
	attack_index = attack_indx
	attacking = true
	$ComboTimer.stop()

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
		knockback_velocity = 100 if area.get_parent().direction.x > 0 else -100
		knocked_back = true
		health -= 1
		if health <= 0:
			queue_free()
