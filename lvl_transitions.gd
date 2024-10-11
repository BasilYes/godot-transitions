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

var default_fade: Fade = null
var fade_in: Fade = null
var fade_out: Fade = null

var is_headless: bool = false
var multiplayer_spawner: MultiplayerSpawner = null

func _ready() -> void:
	if has_node("/root/EMSession"):
		var session: Node = get_node("/root/EMSession")
		if (get_tree().current_scene.scene_file_path.get_file()
				!= "lvl_multiplayer_spawner.tscn"):
			get_tree().change_scene_to_packed.call_deferred(
					preload("lvl_multiplayer_spawner.tscn")
			)
			while (not get_tree().current_scene
					or get_tree().current_scene.scene_file_path.get_file()
					!= "lvl_multiplayer_spawner.tscn"):
				await get_tree().node_added
		multiplayer_spawner = get_tree().current_scene
	if DisplayServer.get_name() == "headless":
		is_headless = true
		var lvl_path: String = ProjectSettings.get_setting(
			"easy_multiplayer/server_scene", ""
		)
		if not multiplayer_spawner:
			return
		if lvl_path:
			var new_lvl: Node = load(lvl_path).instantiate()
			multiplayer_spawner.add_child(new_lvl)
		return
	layer = 101
	default_fade = Fade.new()
	fade_in = default_fade
	add_child(default_fade)
	default_fade.size = get_viewport().get_visible_rect().size
	default_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	default_fade.color = Color.BLACK

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

@rpc("authority", "call_remote", "reliable")
func swap_level(
		lvl_path: String,
		fade_scene: PackedScene = null,
		key: String = ""
) -> void:
	if level_swaping:
		push_warning("Level swap denied because other levels swaping in progress")
		return
	level_swaping = true
	await _pre_swap(fade_scene, key)
	if multiplayer_spawner:
		var new_lvl: Node = load(lvl_path).instantiate()
		multiplayer_spawner.add_child(new_lvl)
		if not new_lvl.is_node_ready():
			await new_lvl.ready
	else:
		await get_tree().change_scene_to_file(lvl_path)
		while not get_tree().current_scene\
				or get_tree().current_scene.scene_file_path != lvl_path:
			await get_tree().node_added
		await get_tree().current_scene.ready
	await _post_swap()
	level_swaping = false

func _pre_swap(
	fade_scene: PackedScene = null,
	key: String = ""
) -> void:
	if is_headless:
		return
	var node: Node = null
	fade_out = null
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
		fade_out = default_fade
	# fade_out.visible = true
	await fade_out.fade_out()
	default_fade.color = fade_out.color

func _post_swap() -> void:
	if is_headless:
		return
	if fade_in != fade_out:
		fade_out.visible = false
	await fade_in.fade_in()
	fade_in.visible = false
