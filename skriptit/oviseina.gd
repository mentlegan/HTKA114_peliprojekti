extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body) -> void:
	if body.is_in_group("valopallo"):
		body.start_destroy()
		Globaali.avaa_seinaovi()
		self.queue_free()
