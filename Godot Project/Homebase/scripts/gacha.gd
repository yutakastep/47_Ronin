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
	$PulledLabel.text = ronin_name.substr(0, ronin_name.length() - 5) + "!"
	
func pull_ronin():
	var files = []
	var dir = DirAccess.open("res://Ronins/scenes/47/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				files.append(file_name)
			file_name = dir.get_next()
			
	ronin_name = files.pick_random()
	ronin_sprite = load("res://Ronins/scenes/47/" + ronin_name).instantiate()
	
func show_sprite():
	$ShowcaseRonin.apply_variant(ronin_sprite.body, ronin_sprite.head, ronin_sprite.color)

func reset():
	$AnimationPlayer.play("RESET")
