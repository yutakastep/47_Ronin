extends Node2D
var balls = ["blue", "green", "red", "orange", "purple", "yellow"]

var ronin_sprite : CharacterBody2D
var ronin_name : String

func spin():
	reset()
	$AnimatedSprite2D.play("spin")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play(balls[RandomNumberGenerator.new().randi_range(0, 5)])
	await $AnimatedSprite2D.animation_finished
	$AnimationPlayer.play("MoveMachine")
	pull_ronin()
	show_sprite()
	$PulledLabel.text = ronin_name.lstrip("res://Ronins/scenes/Locked Ronin/").rstrip(".tscn") + "!"
	
func pull_ronin():
	ronin_name = PlayerManager.locked_ronins.pick_random()
	PlayerManager.unlocked_ronins.append(ronin_name)
	PlayerManager.locked_ronins.erase(ronin_name)
	ronin_sprite = load(ronin_name).instantiate()
	PlayerManager.add_ronin()
	
func show_sprite():
	$ShowcaseRonin.apply_variant(ronin_sprite.body, ronin_sprite.head, ronin_sprite.color)

func reset():
	$AnimationPlayer.play("RESET")
