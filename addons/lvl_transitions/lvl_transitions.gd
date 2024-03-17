extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func swap_level(path: String, fade_out: Fade = null) -> void:
	if not fade_out:
		if get_tree().get_first_node_in_group("default_fade") is Fade:
			fade_out = get_tree().get_first_node_in_group("default_fade")
		elif get_tree().get_first_node_in_group("fade") is Fade:
			fade_out = get_tree().get_first_node_in_group("fade")
	if fade_out:
		await fade_out.fade_out()
		color_rect.color = fade_out.color
	visible = true
	await get_tree().change_scene_to_file(path)
	await get_tree().node_added
	visible = false
