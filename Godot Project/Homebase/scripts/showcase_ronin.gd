extends BaseRonin

func apply_variant(body, head, color):
	var body_map = ["Sword", "Spear", "Kunai"]
	
	var color_map = ["Red", "Blue", "Brown", "Green", "Purple"]
	var head_map = []
	
	match body:
		0:
			head_map = ["Hat", "Hair", "Chonmage"]
		1:
			head_map = ["Helmet", "Hair", "Chonmage"]
		2:
			head_map = ["Wrap", "Hair", "Chonmage"]

	var base_path = "res://Ronins/sprites/%s/%s/%s/" % [body_map[body], head_map[head], color_map[color]]
	
	var sheet_map = {"breathing":   load(base_path + "breathing.png")}
	
	var frames = $AnimatedSprite2D.sprite_frames
	for anim_name in frames.get_animation_names():
		for i in frames.get_frame_count(anim_name):
			var atlas = frames.get_frame_texture(anim_name, i)
			if atlas == null:
				continue
			if not atlas is AtlasTexture:
				continue
			atlas.atlas = sheet_map.get(anim_name)

func _process(delta: float) -> void:
	$AnimatedSprite2D.play("breathing")
