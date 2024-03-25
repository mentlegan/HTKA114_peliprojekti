## Paavo 25.3.2024
## TODO: Parempi toteutus SS2D-noden kopioimiseen, ei ole kriittinen
extends Node2D


var reunat = preload("res://smart_shape_reunat.tres")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Lisätään SS2D_Shape-nodeille varjot ja collisionit.
	self.lisaa_varjot_ja_collisionit()


## Luo jokaiselle SS2D_Shape-lapsinodelle LightOccluder2D- ja CollisionPolygon2D-nodet.
## Asettaa samalla SS2D_Shape-noden uudeksi vanhemmaksi StaticBody2D-noden, jotta
## CollisionPolygon2D toimisi.
##
## Esimerkki nodejen rakenteesta ennen funktion kutsua:
##
##   Tiilet
##   ├── SS2D_Shape
##   └── SS2D_Shape2
##
## Funktiokutsun jälkeen:
##
##   Tiilet
##   ├── StaticBody2D
##   │   ├── CollisionPolygon2D
##   │   ├── LightOccluder2D
##   │   └── SS2D_Shape
##   └── StaticBody2D2
##       ├── CollisionPolygon2D
##       ├── LightOccluder2D
##       └── SS2D_Shape2
##
func lisaa_varjot_ja_collisionit():
	# Käydään läpi jokainen lapsi-node.
	for lapsi in get_children():
		# Käsitellään pelkästään SS2D_Shape-nodeja
		if lapsi is SS2D_Shape:
			# Luodaan StaticBody2D, jonka lapseksi asetetaan nykyinen SS2D_Shape
			var static_body = StaticBody2D.new()
			lapsi.reparent(static_body)
			
			# Haetaan seuraavaksi SS2D_Shape:n pisteet ja luodaan niiden perusteella
			# uusi PackedVector2Array, jonka pisteet on sovitettu oikein maailman koordinaatistoon
			# SS2D_Shapen keskipisteen perusteella.
			var ss2d_sijainti = lapsi.global_position # SS2D_Shapen keskipiste
			# Hyödynnetään SS2D_Shapen pisteiden luomiseen noden omaa metodia.
			var suhteelliset_pisteet = lapsi.generate_collision_points()
			# Luodaan PackedVector2Array sovitetuille pisteille
			var sovitetut_pisteet = PackedVector2Array()
			
			# Käydään SS2D_Shapen suhteelliset pisteet läpi
			for piste in suhteelliset_pisteet:
				# Luodaan Vector2, jonka koordinaatteja siirretään SS2D_Shapen keskipisteen verran
				var siirretty_piste = Vector2(piste.x + ss2d_sijainti.x, piste.y + ss2d_sijainti.y)
				sovitetut_pisteet.append(siirretty_piste)
			
			# Nyt on käytössä sovitetut pisteet, jonka perusteella luodaan nodet varjoille ja
			# collisioneille
			var occluder = LightOccluder2D.new()
			var occluder_polygon = OccluderPolygon2D.new()
			var collision_polygon = CollisionPolygon2D.new()
			
			# Asetetaan sovitetut pisteet nodejen polygoneiksi
			occluder_polygon.set_polygon(sovitetut_pisteet)
			occluder.set_occluder_polygon(occluder_polygon)
			collision_polygon.set_polygon(sovitetut_pisteet)
			
			# Lisätään varjot ja collisionit StaticBody2D:n lapsiksi
			static_body.add_child(occluder)
			static_body.add_child(collision_polygon)

			# Lisätään uusi SS2D-node reunojen renderöimistä varten light_mask:in layerilla 2
			var ss2d = lapsi.duplicate() # TODO: Tähän jokin parempi toteutus, SmartShape2D.new() yms.
			ss2d.shape_material = reunat # Asetetaan uusi materiaali SS2D-nodelle
			ss2d.z_index = 1 # Nostetaan aiemman ss2d-noden päälle

			# Korotetaan light_mask:ia, tämän avulla saadaan renderoitua pelkästään tiettyjen valojen avulla
			ss2d.light_mask = 2 

			# Lisätään lopuksi StaticBody2D ja SS2D Tiilet-noden lapseksi
			self.add_child(static_body)
			self.add_child(ss2d)
