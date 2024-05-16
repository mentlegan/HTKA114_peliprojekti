extends Area2D

## Pelaajan alkaa ottamaan myrkkyä osuessaan sieneen
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"):
		print_debug("Kuolit PIIKKIIN")
		body.meneta_elamia(100)
