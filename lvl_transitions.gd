extends CanvasLayer

signal level_swap
signal level_swaped
signal faded_out
signal faded_in

var level_swaping: bool = false :
	set(value):
		level_swaping = value
		if value:
			level_swap.emit()
		else:
			level_swaped.emit()

var default_fade: Fade = null
var fade_in_scene: Fade = null
var fade_out_scene: Fade = null

var is_headless: bool = false
var multiplayer_spawner: MultiplayerSpawner = null
var _manual_fade_in: bool = false

func _ready() -> void:
	if has_node("/root/EMSession"):
		var session: Node = get_node("/root/EMSession")
		if ProjectSettings.get_setting("easy_multiplayer/multiplayer_type", 0) == 0:
			if not get_tree().current_scene is MultiplayerSpawner:
				get_tree().change_scene_to_packed.call_deferred(
						load("uid://c5h0xfj8w4uda")
				)
				while not get_tree().current_scene is MultiplayerSpawner:
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
	fade_in_scene = default_fade
	add_child(default_fade)
	default_fade.size = get_viewport().get_visible_rect().size
	default_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	default_fade.color = Color.BLACK


func manual_fade_in() -> void:
	if _manual_fade_in:
		return
	_manual_fade_in = true
	fade_in_scene.fade_in_on_start = false
	if fade_in_scene.tween:
		fade_in_scene.tween.kill()
		fade_in_scene.progress = 1.0
	await faded_in
	_manual_fade_in = false


func set_fade_in(
		fade_scene: PackedScene,
		key: String = ""
) -> void:
	var node: Node = null
	if key:
		node = get_node_or_null(key)
	if node is Fade:
		fade_in_scene = node
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
	await fade_out(fade_scene, key)
	if multiplayer_spawner:
		var new_lvl: Node = load(lvl_path).instantiate()
		multiplayer_spawner.add_child(new_lvl)
		if not new_lvl.is_node_ready():
			await new_lvl.ready
	else:
		await get_tree().change_scene_to_file(lvl_path)
		while not get_tree().current_scene:
			await get_tree().physics_frame
		if not get_tree().current_scene.is_node_ready():
			await get_tree().current_scene.ready
	if _manual_fade_in:
		await faded_in
	else:
		await fade_in()
	level_swaping = false


func fade_out(
	fade_scene: PackedScene = null,
	key: String = ""
) -> void:
	if is_headless:
		return
	if fade_out_scene and fade_out_scene.progress != 0:
		if fade_out_scene.progress != 1.0:
			await faded_out
		return
	fade_out_scene = find_or_create_fade(fade_scene, key)
	await fade_out_scene.fade_out()
	default_fade.color = fade_out_scene.color
	faded_out.emit()

func fade_in(
		fade_scene: PackedScene = null,
		key: String = ""
) -> void:
	if is_headless:
		return
	fade_in_scene = find_or_create_fade(fade_scene, key)
	if fade_out_scene and fade_in_scene != fade_out_scene:
		fade_out_scene.visible = false
	await fade_in_scene.fade_in()
	fade_in_scene.visible = false
	faded_in.emit()


func find_or_create_fade(
		fade_scene: PackedScene = null,
		key: String = ""
) -> Fade:
	var node: Node = null
	var fade_node: Fade = null
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
		fade_node = node
	if not fade_node:
		fade_node = default_fade
	return fade_node
