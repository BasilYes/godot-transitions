extends CanvasLayer

@onready var default: Fade = $DefaultFade

var level_swaping: bool = false

func swap_level(path: String, fade_out: Fade = null) -> void:
	if level_swaping:
		push_warning("Level swap denied because other levels swaping in progress")
		return
	level_swaping = true
	if not fade_out:
		if get_tree().get_first_node_in_group("default_fade") is Fade:
			fade_out = get_tree().get_first_node_in_group("default_fade")
		else:
			fade_out = default
	if fade_out:
		await fade_out.fade_out()
		default.color = fade_out.color
	default.visible = true
	await get_tree().change_scene_to_file(path)
	await get_tree().node_added
	await get_tree().current_scene.ready
	var use_default_as_fade_in: bool = true
	for i in get_tree().get_nodes_in_group("fade"):
		if i is Fade and i.fade_in_on_start:
			use_default_as_fade_in = false
			break
	if use_default_as_fade_in:
		await default.fade_in()
	default.visible = false
	level_swaping = false
