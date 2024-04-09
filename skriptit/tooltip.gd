extends Area2D


## Piilotetaan tooltip pelin alussa
func _ready():
	visible = false


## Asetetaan tooltip näkyviin, kun pelaaja astuu sen alueelle
func _on_body_entered(body):
	if body is Pelaaja:
		visible = true


## Piilotetaan tooltip, kun pelaaja poistuu sen alueelta
func _on_body_exited(body):
	if body is Pelaaja:
		visible = false
