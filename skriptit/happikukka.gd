## Harri 9.9.2024
## Happikukan toimintaa
## Ei kenties vielä tarvita muuten kuin class namen laittoon, koska nykyisellään toiminta hoituu helposti pelaajan skriptissä
extends Area2D
class_name Happikukka

var pelaaja = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
