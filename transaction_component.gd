@tool
class_name TransitionComponent
extends Node

enum Action {
	FADE_OUT,
	FADE_IN,
}

@export var instigator: Node
@export var signal_name: String = "ready"
@export var action: Action = Action.FADE_OUT :
	set(value):
		action = value
		notify_property_list_changed()
var fade_scene: PackedScene = null :
	set(value):
		fade_scene = value
		if not key:
			key = fade_scene.resource_name
var key: String = ""
var lvl_path: String = ""

func _ready() -> void:
	if not instigator:
		instigator = get_parent()
	if Engine.is_editor_hint():
		return
	if not instigator.has_signal(signal_name):
		return
	match action:
		Action.FADE_OUT:
			if not FileAccess.file_exists(lvl_path):
				return
			instigator.connect(signal_name,
				LvlTransitions.swap_level.bind(
					lvl_path, fade_scene, key
			))
		Action.FADE_IN:
			instigator.connect(signal_name,
				LvlTransitions.set_fade_in.bind(
					fade_scene, key
			))


func _get_property_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	match action:
		Action.FADE_OUT:
			result.append({
				"name": "lvl_path",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_FILE,
				"hint_string": "*.tscn,*.scn",
			})
	return result
