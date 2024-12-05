extends Area2D
## Editorissa vaihdettava arvo sille, ottaako myrkystä damagea
@export var tekeeko_damagea: bool = true

## Pelaajan alkaa ottamaan myrkkyä osuessaan sieneen
func _on_body_entered(body):
	if tekeeko_damagea and body is Pelaaja:
		body.myrkky_timer()
		body.myrkky_ajastin.one_shot = false


## Lopetetaan myrkyn jatkuminen kun pois sienestä
func _on_body_exited(body):
	if tekeeko_damagea and body is Pelaaja:
		body.myrkky_ajastin.one_shot = true
