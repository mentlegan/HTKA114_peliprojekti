extends Node2D


# TODO: Rivi 26: Tarkista, että CollisionPolygon2D on olemassa.
# Ei pitäisi koskaan tapahtua, ellei sitä ole erikseen poistettu.


# Called when the node enters the scene tree for the first time.
func _ready():
	# Lisätään StaticBody2D-nodeille varjot.
	self.lisaa_varjot()


## Lisää jokaiselle StaticBody2D-tyyppiselle lapsi-nodelle LightOccluder2D:n.
## Toimiakseen, StaticBody2D-nodella on oltava lapsena CollisionPolygon2D.
func lisaa_varjot():
	# Käydään läpi jokainen lapsi-node.
	for child in get_children():
		# Lisätään varjot pelkästään StaticBody2D-nodeille.
		if child is StaticBody2D:
			# Luodaan LightOccluder2D ja sille tarvittava OccluderPolygon2D-node
			var occluder = LightOccluder2D.new()
			var occluder_polygon = OccluderPolygon2D.new()
			
			# Haetaan varjolle asetettava polygoni CollisionPolygon2D:ltä ja
			# asetetaan se varjon polygoniksi.
			var collision_polygon_2d = child.get_node("CollisionPolygon2D")
			occluder_polygon.set_polygon(collision_polygon_2d.get_polygon())
			occluder.set_occluder_polygon(occluder_polygon)
			
			# Lisätään lopuksi LightOccluder2D nykyisen StaticBody2D-noden
			# lapseksi.
			child.add_child(occluder)
