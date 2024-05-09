extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for animaatio in self.get_children():
		if animaatio is AnimatedSprite2D:
			animaatio.play("default")


func _on_body_entered(body) -> void:
	if body is Pelaaja:
		pass
		# Teleportataan kuilun alas transitiolla, ruutu mustaksi esim.
	# Jos valopallo
	elif body.is_in_group("valopallo"):
		body.start_destroy()
