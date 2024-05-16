extends Area2D

## Pelaajan alkaa ottamaan myrkkyä osuessaan sieneen
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"):
		body.meneta_elamia(100)
