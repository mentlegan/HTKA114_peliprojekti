## Paavo 19.4.2024
## Juuso 1.4.2024 korjattu polygonien siirtely
extends Node2D

const ILLUUSION_VAIHTAJA_VISIBLE = preload("res://scenet/illuusion_vaihtaja_visible.tscn")

## SmartShape2D-materiaalit
@export var ss2d_materiaali: Resource


## Kutsutaan, kun pääsee sceneen
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
##   └── SS2D_Shape     <- Voidaan vielä käyttää SS2D_Shape:a,
##                      joka tosin muuttaa .tscn-tiedostoa jokaisella avauksella.
##
## Funktiokutsun jälkeen:
##
##   Tiilet
##   ├── StaticBody2D
##   │   ├── Polygon2D
##   │   ├── CollisionPolygon2D
##   │   ├── LightOccluder2D
##   │   └── SS2D_Shape
##   ├── StaticBody2D2
##   │   ├── Polygon2D2
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
			ss2d._set_material(ss2d_materiaali)

			# Kutsutaan vielä varulta _points_modified
			ss2d._points_modified()
			if lapsi.is_in_group("oviseina"):
				ss2d.add_to_group("oviseina")
				if lapsi.is_in_group("avaaoviseina"):
					ss2d.add_to_group("avaaoviseina")

			# Lisätään SS2D lapseksi
			self.add_child(ss2d)

			# Peitetään tausta Polygon2D:lla
			lapsi.color = Color.BLACK

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
				var siirretty_piste = piste + ss2d_sijainti
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
			if lapsi.is_in_group("oviseina"):
				static_body.add_to_group("oviseina")
				var vaihtaja = ILLUUSION_VAIHTAJA_VISIBLE.instantiate()
				if lapsi.is_in_group("avaaoviseina"):
					vaihtaja.invert = true
					static_body.add_to_group("avaaoviseina")
				static_body.add_child(vaihtaja)
			# Asetetaan light_mask, jotta reunat renderöidään kauempaa
			lapsi.light_mask = 2
			# Nostetaan SS2D node yleisten tasoelementtien ylle
			lapsi.z_index = 2

			# Lisätään lopuksi StaticBody2D ja SS2D Tiilet-noden lapseksi
			self.add_child(static_body)
			#print(static_body.get_groups())
			#self.add_child(ss2d)
