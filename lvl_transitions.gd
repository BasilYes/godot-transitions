extends CanvasLayer

signal level_swap
signal level_swaped

var level_swaping: bool = false :
	set(value):
		level_swaping = value
		if value:
			level_swap.emit()
		else:
			level_swaped.emit()
var default: Fade = null
var fade_in: Fade = null

func _ready() -> void:
	layer = 101
	default = Fade.new()
	fade_in = default
	add_child(default)
	default.set_anchors_preset(Control.PRESET_FULL_RECT)
	default.size = get_viewport().get_visible_rect().size
	default.color = Color.BLACK

func set_fade_in(
		fade_scene: PackedScene,
		key: String = ""
) -> void:
	var node: Node = null
	if key:
		node = get_node_or_null(key)
	if node is Fade:
		fade_in = node
		return
	node = fade_scene.instantiate()
	if not node is Fade:
		return
	add_child(node)
	if key:
		node.name = key
	else:
		node.visibility_changed.connect(func() -> void:
			if not node.visible:
				node.queue_free()
		)


func swap_level(
		lvl_path: String,
		fade_scene: PackedScene = null,
		key: String = ""
) -> void:
	if level_swaping:
		push_warning("Level swap denied because other levels swaping in progress")
		return
	level_swaping = true
	var node: Node = null
	var fade_out: Fade = null
	if key:
		node = get_node_or_null(key)
	if not node and fade_scene:
		node = fade_scene.instantiate()
		if node is Fade:
			add_child(node)
			if key:
				node.name = key
			else:
				node.visibility_changed.connect(func() -> void:
					if not node.visible:
						node.queue_free()
				)
		else:
			push_warning("fade_scene don't extends Fade")
	if node is Fade:
		fade_out = node
	if not fade_out:
		fade_out = default
	# fade_out.visible = true
	await fade_out.fade_out()
	default.color = fade_out.color
	# fade_out.visible = true
	await get_tree().change_scene_to_file(lvl_path)
	await get_tree().node_added
	await get_tree().current_scene.ready
	# fade_in.visible = true
	# fade_in =
	if fade_in != fade_out:
		fade_out.visible = false
	await fade_in.fade_in()
	fade_in.visible = false
	level_swaping = false
