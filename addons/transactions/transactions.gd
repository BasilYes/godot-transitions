extends CanvasLayer


func swap_level(path: String, fade_out: Fade = null) -> void:
	if fade_out:
		await fade_out.fade_out()
	visible = true
	await get_tree().change_scene_to_file(path)
	await get_tree().node_added
	visible = false
