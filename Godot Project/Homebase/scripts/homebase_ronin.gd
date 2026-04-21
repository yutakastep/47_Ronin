extends SwordRonin

var moveable = true

func _ready():
	speed = 300
	apply_variant()

func _process(delta: float) -> void:
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walking")
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walking")
	else:
		$AnimatedSprite2D.play("breathing")

func _physics_process(delta):
	velocity.y += gravity * delta

	velocity.x = Input.get_axis("ui_left", "ui_right") * speed if moveable else 0
	
	move_and_slide()
