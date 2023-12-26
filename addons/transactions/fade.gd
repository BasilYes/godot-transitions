class_name Fade
extends ColorRect

signal faded_in
signal faded_out

@export var fade_in_duration: float = 1.0
@export var fade_in_transaction_type: Tween.TransitionType = Tween.TRANS_LINEAR
@export var fade_in_on_start: bool = false
@export var fade_out_duration: float = 1.0
@export var fade_out_transaction_type: Tween.TransitionType = Tween.TRANS_LINEAR
var progress: float = 0.0 :
	set(value):
		progress = value
		_update_progress(value)


func _ready() -> void:
	progress = 0.0
	visible = false
	if fade_in_on_start and not Engine.is_editor_hint():
		fade_in()


func fade_in():
	visible = true
	progress = 1.0
	var tween: Tween = get_tree().create_tween().set_trans(fade_in_transaction_type)
	tween.tween_property(self, "progress", 0.0, fade_in_duration)
	await tween.finished
	faded_in.emit()
	visible = false


func fade_out():
	visible = true
	progress = 0.0
	var tween: Tween = get_tree().create_tween().set_trans(fade_out_transaction_type)
	tween.tween_property(self, "progress", 1.0, fade_in_duration)
	await tween.finished
	faded_out.emit()


func _update_progress(value: float) -> void:
	modulate.a = progress
