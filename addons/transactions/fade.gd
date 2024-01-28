@tool
class_name Fade
extends ColorRect

signal faded_in
signal faded_out

@export var fade_in_duration: float = 1.0
@export var fade_in_transaction_type: Tween.TransitionType
@export var fade_in_ease_type: Tween.EaseType
@export var fade_in_on_start: bool = true
@export var fade_out_duration: float = 1.0
@export var fade_out_transaction_type: Tween.TransitionType
@export var fade_out_ease_type: Tween.EaseType
var progress: float = 0.0 :
	set(value):
		progress = value
		_update_progress(value)


func _ready() -> void:
	visible = false
	if not Engine.is_editor_hint():
		if fade_in_on_start:
			fade_in()
	else:
		layout_mode = 1
		set_anchors_preset(PRESET_FULL_RECT)
		set_size.call_deferred(
			Vector2i(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"),
			))
		add_to_group("fade", true)


func fade_in():
	visible = true
	progress = 1.0
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(fade_in_transaction_type)
	tween.set_ease(fade_in_ease_type)
	tween.tween_property(self, "progress", 0.0, fade_in_duration)
	await tween.finished
	faded_in.emit()
	visible = false


func fade_out():
	visible = true
	progress = 0.0
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(fade_out_transaction_type)
	tween.set_ease(fade_out_ease_type)
	tween.tween_property(self, "progress", 1.0, fade_in_duration)
	await tween.finished
	faded_out.emit()


func _update_progress(value: float) -> void:
	modulate.a = progress
