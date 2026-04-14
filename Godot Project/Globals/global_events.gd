extends Node
signal spawn_enemy(scene, location)
signal ronin_death()
signal game_lose()
signal interact()

var next_floor_level = 0
var floor_count = 0
var platform_death_spawn_point = Vector2(0, 0)
