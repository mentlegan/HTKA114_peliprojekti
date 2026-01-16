extends Area2D


# Unlockataan kilpi pelaajaan osuessa
func _on_body_entered(body):
	if body is Pelaaja:
		body.unlock_kilpi()
		self.queue_free()
