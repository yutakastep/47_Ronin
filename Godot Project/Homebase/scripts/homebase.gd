extends Node2D

func _ready() -> void:
	$Background/Tengu/Tengu.animation = "looking"

func _process(delta: float) -> void:
	if $Background/HomebaseRonin.global_position.x > $Background/Tengu/Tengu.global_position.x:
		$Background/Tengu/Tengu.frame = 0
	else:
		$Background/Tengu/Tengu.frame = 1
