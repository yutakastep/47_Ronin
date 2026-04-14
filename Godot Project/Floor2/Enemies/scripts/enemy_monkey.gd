class_name EnemyMonkey extends Floor2Enemies

@onready var state = "waiting"
@onready var speed = 20
@onready var gravity = 500
@onready var knockback_velocity = 0
@onready var poop = load("res://misc/scenes/poop.tscn")

var spawn_position : Vector2
var player : CharacterBody2D
var direction = Vector2.ZERO
var yonder = 0
var shot = false;

func _ready() -> void:
	super()
	$ShootTimer.start(2)

func _process(delta: float) -> void:
	if !dying:
		match state:
			"waiting":
				if !is_instance_valid(player):
					return
				waiting(player.global_position)
				if yonder < 0:
					$AnimatedSprite2D.flip_h = false
				elif yonder > 0:
					$AnimatedSprite2D.flip_h = true
			"shooting":
				shoot($AnimatedSprite2D.flip_h, Vector2(global_position.x + 5, global_position.y + 3))
				shot = true
				state = "attacking"
			"attacking":
				$AnimatedSprite2D.play("shoot")
				if $AnimatedSprite2D.frame == 6 and ! shot:
					state = "shooting"
			
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
			if state == "waiting_pending":
				state = "waiting"
	elif state == "waiting":
		yonder = ((direction.x*speed) - yonder) * delta * .75
	move_and_slide()

func waiting(target):
	direction.x = (target.x - global_position.x)
	
func shoot(direction, position):
	var instance = poop.instantiate()
	instance.direction.x = 1 if direction else -1
	instance.spwnPos = position
	add_child.call_deferred(instance)

func _on_animated_sprite_2d_animation_finished() -> void:
		$ShootTimer.start(1)
		shot = false
		state = "waiting"

func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	state = "attacking"

func _on_hit_detection_area_entered(area: Area2D) -> void:
	print("monkey hit")
	$Flash.play("hit")
	
	knockback_velocity = -100 if direction.x > 0 else 100
	knocked_back = true
	
	# take_damage declared in base_enemy_floor1, takes damage amount as argument
	if take_damage(1):
		dying = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		death()
