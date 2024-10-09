extends MultiplayerSpawner


func _enter_tree() -> void:
	spawn_path = "."
	var scene_list: Array[String] = ProjectSettings.get_setting(EMEditorPlugin.SCENE_LIST,
			Array([], TYPE_STRING, "", null))
	var server_scene: String = ProjectSettings.get_setting(EMEditorPlugin.SERVER_SCENE, "")
	if not server_scene in scene_list:
		scene_list.append(server_scene)
	for i in scene_list:
		add_spawnable_scene(i)
	for i in get_spawnable_scene_count():
		print(get_spawnable_scene(i))
