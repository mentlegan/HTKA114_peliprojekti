extends Area2D
signal pelaaja_kuollut
var pelaaja = null

## Pelaajan kuolee osuessaan piikkeihin
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"):
		pelaaja = body
		pelaaja_kuollut.emit()
