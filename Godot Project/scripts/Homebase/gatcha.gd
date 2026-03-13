extends Control

var rng = RandomNumberGenerator.new()

var ranks = ['D', 'C', 'B', 'A', 'S']
var weights = PackedFloat32Array([10, 5, 3, 1, 0.5])
var character_stats = []
var mean = 0.0

func pull():
	for i in range(5):
		var rand_index = rng.rand_weighted(weights)
		character_stats.append(rand_index)
		mean += rand_index
		
func draw_power_line():
	$Polygon2D.set_polygon(PackedVector2Array([
		Vector2(160, 89 + 12*(character_stats[1]+1)),
		Vector2(160 - 9*(character_stats[4]+1), 89 + 6*(character_stats[4]+1)),
		Vector2(160 - 9*(character_stats[3]+1), 89 - 6*(character_stats[3]+1)),
		Vector2(160, 89 - 12*(character_stats[0]+1)),
		Vector2(160 + 9*(character_stats[2]+1), 89 - 6*(character_stats[2]+1))]))


	

func _ready() -> void:
	pull()
	print($Line2D.points)
	draw_power_line()
	print($Line2D.points)
	print(character_stats)
	print(mean/5)
	print(ranks[int(mean/5)])
	
