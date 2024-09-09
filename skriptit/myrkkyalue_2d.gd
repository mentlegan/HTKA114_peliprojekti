extends Area2D

## Pelaajan alkaa ottamaan myrkkyä tullessaan alueelle
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"):
		body.myrkkyalue_timer()
		body.myrkkyalue_ajastin.one_shot = false

## Lopetetaan myrkyn jatkuminen kun pois alueelta
func _on_body_exited(body):
	if body.is_in_group("Pelaaja"):
		body.myrkkyalue_ajastin.one_shot = true
