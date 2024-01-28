@tool
class_name TextureFade
extends Fade


func _ready() -> void:
	super()
	if Engine.is_editor_hint() and not material:
		material = preload("res://addons/transactions/resources/texture_fade_material.tres")


func _update_progress(value: float) -> void:
	(material as ShaderMaterial).set_shader_parameter("progress", progress)
