## Paavo 25.3.2024
## Juuso 1.4.2024 korjattu polygonien siirtely
## TODO: Parempi toteutus SS2D-noden kopioimiseen, ei ole kriittinen
extends Node2D


# SmartShape2D-materiaalit
var reunat = preload("res://tres-tiedostot/smart_shape_reunat.tres")
var tiili = preload("res://tres-tiedostot/smart_shape_tiili.tres")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Muutetaan Polygon2D-nodet SS2D_Shape-nodeiksi ja lisätään niille varjot ja collisionit.
	self.lisaa_varjot_ja_collisionit()


## Muuttaa jokaisen Polygon2D-lapsinoden SS2D_Shape-nodeksi ja lisää sille LightOccluder2D- ja CollisionPolygon2D-nodet.
## Asettaa samalla SS2D_Shape-noden uudeksi vanhemmaksi StaticBody2D-noden, jotta
## CollisionPolygon2D toimisi.
##
## Esimerkki nodejen rakenteesta ennen funktion kutsua:
##
##   Tiilet
##   ├── Polygon2D
##   ├── Polygon2D2
##   ├── SS2D_Shape     <- Voidaan vielä käyttää SS2D_Shape:a,
##                      joka tosin muuttaa .tscn-tiedostoa jokaisella avauksella.
##
## Funktiokutsun jälkeen:
##
##   Tiilet
##   ├── StaticBody2D
##   │   ├── CollisionPolygon2D
##   │   ├── LightOccluder2D
##   │   └── SS2D_Shape
##   ├── StaticBody2D2
##   │   ├── CollisionPolygon2D
##   │   ├── LightOccluder2D
##   │   └── SS2D_Shape
##   └── StaticBody2D3
##       ├── CollisionPolygon2D
##       ├── LightOccluder2D
##       └── SS2D_Shape
##
func lisaa_varjot_ja_collisionit():
	# Käydään läpi jokainen lapsi-node. Muutetaan Polygon2D-nodet SS2D-nodeiksi.
	for lapsi in get_children():
		if lapsi is Polygon2D:
			# Haetaan Polygon2D:n PackedVector2Array
			var polygon = lapsi.get_polygon()

			# Luodaan SS2D
			var ss2d = SS2D_Shape.new()

			# Lisätään SS2D:lle Polygon2D:n vektorit
			for vektori in polygon:
				ss2d.add_point(vektori)

			# Asetetaan SS2D:n sijainti
			ss2d.global_position = lapsi.global_position
			
			# Kutsutaan close_shape:a, jotta collisionit toimisivat
			ss2d.close_shape()

			# Asetetaan SS2D:lle materiaali
			ss2d._set_material(tiili)

			# Kutsutaan vielä varulta _points_modified
			ss2d._points_modified()

			# Lisätään SS2D lapseksi ja poistetaan Polygon2D
			self.add_child(ss2d)
			lapsi.queue_free()

	# Käydään uudestaan läpi jokainen lapsi-node.
	for lapsi in get_children():
		# Käsitellään pelkästään SS2D_Shape-nodeja,
		# tässä on nyt mukana aiemmin muutetut Polygon2D-nodet.
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
