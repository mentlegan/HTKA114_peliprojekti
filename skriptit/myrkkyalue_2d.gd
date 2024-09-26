extends Area2D
## Editorissa vaihdettava arvo sille, ottaako myrkystä damagea
@export var tekeeko_damagea: bool = true

## Pelaajan alkaa ottamaan myrkkyä tullessaan alueelle
func _on_body_entered(body):
	if tekeeko_damagea:
		if body.is_in_group("Pelaaja"):
			body.myrkkyalue_timer()
			body.myrkkyalue_ajastin.one_shot = false


## Lopetetaan myrkyn jatkuminen kun pois alueelta
func _on_body_exited(body):
	if tekeeko_damagea:
		if body.is_in_group("Pelaaja"):
			body.myrkkyalue_ajastin.one_shot = true
