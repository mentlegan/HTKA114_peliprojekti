extends Area2D
signal pelaaja_kuollut

## Pelaajan kuolee osuessaan piikkeihin
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"):
		body.meneta_elamia(100)
