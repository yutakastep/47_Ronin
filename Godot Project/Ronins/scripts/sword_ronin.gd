extends CharacterBody2D

@export var speed = 60
@export var jump_speed = -200
@export var gravity = 500
var combo_count: int = 0
@onready var combo_timer: Timer = $ComboTimer

var spawn_position : Vector2
var attack_index = 0
var sheathing = false
var timedout = false
var attacking = false
var jumping = false

func _ready() -> void:
	global_position = spawn_position

func _process(delta: float) -> void:
	if !sheathing:
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
		elif !attacking and !jumping and attack_index == 0:
			if Input.is_action_just_pressed("space"):
				$AnimatedSprite2D.play("jump")
				jumping = true
			elif velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("walking")
			elif velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walking")
			else:
				$AnimatedSprite2D.play("breathing")
	
	

func _physics_process(delta):

	# Add gravity every frame
	velocity.y += gravity * delta
	
	if !attacking && $ComboTimer.is_stopped():
		velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	elif !jumping && !sheathing:
		velocity.x = 0
	move_and_slide()

	# Only allow jumping when on the ground
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jump_speed

func attack(attack_indx, attack) -> void:
	if(1 < attack_indx && attack_indx < 4 && jumping):
		return
	$AnimatedSprite2D.play(attack)
	attack_index = attack_indx
	attacking = true
	$ComboTimer.stop()

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
