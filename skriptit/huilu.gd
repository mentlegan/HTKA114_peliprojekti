extends Area2D
class_name Huilu

## Huilun raycast
@onready var raycast = $RayCast2D

## Äänen taajuus, asetetaan pelaaja.gd:ssä
var aanen_taajuus = 1

## Tarkistaa, osuuko huilun raycast terrainiin pelaajan ja annetun noden välillä
func osuu_terrainiin(node):
	if raycast.is_enabled():
		raycast.set_target_position(node.global_position - raycast.global_position)
		raycast.force_raycast_update()
		
		# Tarkistetaan, ollaanko osuttu oveen.
		var collider = raycast.get_collider()
		if collider != null and collider.has_method("get_name"):
			var nimi = collider.get_name()
			# ... Jos ollaan, lisätään ovi poikkeuksiin ja tarkistetaan collisionit uudestaan
			# rekursiivisesti.
			if nimi == "Osuu" or nimi == "Kimpoaa":
				raycast.add_exception(collider)
				return osuu_terrainiin(node)
		
		# Tässä vaiheessa ei collisioni voi olla enää ovi.
		# Palautetaan totuusarvo, osutaanko SS2D-terrainiin.
		return raycast.is_colliding()
	# Palautetaan false, jos raycastin collisionit on pois päältä
	return false
