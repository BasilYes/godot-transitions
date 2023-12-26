extends Fade


func _update_progress(value: float) -> void:
	(material as ShaderMaterial).set_shader_parameter("progress", progress)
