class_name EnemyGunman extends Floor1Enemies

@onready var state = "waiting"
@onready var speed = 20
@onready var gravity = 500
@onready var knockback_velocity = 0
@onready var bullet = load("res://misc/scenes/bullet.tscn")

var spawn_position : Vector2
var player : CharacterBody2D
var direction = Vector2.ZERO
var yonder = 0

var near_player = false
var knocked_back = false

func _ready() -> void:
	super()
	$ShootTimer.start(2)

func _process(delta: float) -> void:
	
	match state:
		"waiting":
			if !is_instance_valid(player):
				return
			waiting(player.global_position)
			if yonder < 0:
				$AnimatedSprite2D.flip_h = true
				$HitDetection.scale.x = -1
			elif yonder > 0:
				$AnimatedSprite2D.flip_h = false
				$HitDetection.scale.x = 1
		"shooting":
			shoot($AnimatedSprite2D.flip_h, global_position)
			state = "attacking"
		"attacking":
			$AnimatedSprite2D.play("shoot")
			
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
	var instance = bullet.instantiate()
	instance.direction.x = -1 if direction else 1
	instance.spwnPos = position
	add_child.call_deferred(instance)

func _on_animated_sprite_2d_animation_finished() -> void:
		$ShootTimer.start(1)
		state = "waiting"

func _on_shoot_timer_timeout() -> void:
	$ShootTimer.stop()
	state = "shooting"

func _on_hit_detection_area_entered(area: Area2D) -> void:
	print("gunman hit")
	$Flash.play("hit")
	
	knockback_velocity = -100 if direction.x > 0 else 100
	knocked_back = true
	
	# take_damage declared in base_enemy_floor1, takes damage amount as argument
	take_damage(1)
