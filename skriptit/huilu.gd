extends Area2D
class_name Huilu


## Äänen taajuus, asetetaan pelaaja.gd:ssä
var aanen_taajuus = 1
## Huilun raycast
@onready var raycast = $RayCast2D


## Tarkistaa, osuuko huilun raycast terrainiin pelaajan ja annetun noden välillä
func osuu_terrainiin(node):
	if raycast.is_enabled():
		raycast.set_target_position(node.global_position - raycast.global_position)
		raycast.force_raycast_update()
		return raycast.is_colliding()
	return false
