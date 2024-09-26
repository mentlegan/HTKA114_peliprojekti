extends Area2D
class_name Vesi2D
## Alue, jonka CollisionShape2D-nodeilla on vettä.
## Vedenpinta voidaan asettaa funktiolla aseta_vedenpinta(0..1) tai aseta_vedenpinta_merkkiin()
## Lumpeita voi lisätä asettamalla niitä CollisionShape2D-nodejen lapsiksi.

## TODO: Käsittele päällekkäisten CollisionShape2D-nodejen aiheuttamat vesi-shaderin viat
## TODO: Vaihda lumpeen varren pituutta


## Vesialueen CollisionShape2D:t, määrittää missä ja kuinka korkealla vesi on.
var collision_shapet = []
## Vedenpinnan korkein mahdollinen y-koordinaatti
var vedenpinta = null
## Vedenpohjan alhaisin mahdollinen y-koordinaatti
var vedenpohja = null
## Ennalta määritetyt merkit, johon vedenpinta voidaan asettaa (liukuluvun 0..1 sijaan)
var vedenpinnan_merkit = []
## Ensimmäinen Marker2D
var ensimmainen_merkki = null
## Seuraavan merkin indeksi
var seuraava_merkki = 0
## Vedenpinnan vaihtamisen Tween
var tween: Tween
## Veden shaderi
var vesi_shader = preload("res://tres-tiedostot/vesi.tres")
## Veden valo
var vesi_pointlight = preload("res://scenet/vesi2d_pointlight2d.tscn")
## Vedenpinnan muuttumisen kesto
@export var animaation_kesto: float = 10
## Animaation TransitionType
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
## Animaation EaseType
@export var ease_type: Tween.EaseType = Tween.EASE_IN
## Otetaanko vedenpinnan nostamisessa huomioon CollisionShape2D:n korkeus.
## Jos true, CollisionShape2D:n vesialue ei voi nousta editorissa asetettua hitboxia korkeammalle.
## Jos false, vedenpinnan maksimikorkeus määräytyy Vesi2D:n korkeimman CollisionShape2D:n mukaan.
@export var maksimikorkeus_collisionshapella: bool = false


func _ready():
	# Etsitään vesialueen lapsista CollisionShape2D:t.
	for lapsi in get_children():
		if lapsi is CollisionShape2D:
			if lapsi.shape is RectangleShape2D:
				# Luodaan sprite2d, joka sisältää shaderin
				var sprite2d = Sprite2D.new()
				var canvas_texture = CanvasTexture.new()
				var pointlight = vesi_pointlight.instantiate()

				# Asetetaan Sprite2D:n sijainti ja koko vastaamaan CollisionShape2D:ta
				# ja asetetaan sille tyhjä CanvasTexture
				sprite2d.set_texture(canvas_texture)
				sprite2d.set_region_enabled(true)
				sprite2d.set_region_rect(Rect2(0, 0, 1, 1))
				sprite2d.light_mask = 0
				sprite2d.set_z_index(20)
				sprite2d.set_material(vesi_shader)
				sprite2d.position = lapsi.position
				sprite2d.scale = lapsi.shape.size

				pointlight.scale = sprite2d.scale
				pointlight.position = sprite2d.position

				self.add_child(sprite2d)
				self.add_child(pointlight)

				# Tarkistetaan, onko vesialueen lapseksi asetettu lumpeita
				var lumpeet = []
				for lapsenlapsi in lapsi.get_children():
					if lapsenlapsi is Lumme:
						var sijainti = lapsenlapsi.global_position
						lapsi.remove_child(lapsenlapsi)
						self.add_child(lapsenlapsi)
						lapsenlapsi.global_position = sijainti
						lapsenlapsi.global_position.y = lapsi.global_position.y - lapsi.shape.size.y * 0.5
						lumpeet.append(lapsenlapsi)

				collision_shapet.append({
					"collision_shape": lapsi,
					"vedenpohja": lapsi.global_position.y + lapsi.shape.size.y * 0.5,
					"vedenpinta": lapsi.global_position.y - lapsi.shape.size.y * 0.5,
					"korkeus": lapsi.shape.size.y,
					"sprite2d": sprite2d,
					"pointlight": pointlight,
					"lumpeet": lumpeet
				})
			else:
				print_debug("Vesi2D nodella (%s) ei ole RectangleShape2D:ta, skipataan" % lapsi.name)
		
		# Lisätään samalla vedenpinnan merkit
		if lapsi is Marker2D:
			vedenpinnan_merkit.append(lapsi)
	
	if vedenpinnan_merkit.size() > 0:
		ensimmainen_merkki = vedenpinnan_merkit[0]
	
	# Asetetaan veden korkein ja alhaisin piste
	for obj in collision_shapet:
		if not vedenpinta or vedenpinta > obj["vedenpinta"]:
			vedenpinta = obj["vedenpinta"]
		if not vedenpohja or vedenpohja < obj["vedenpohja"]:
			vedenpohja = obj["vedenpohja"]
	
	#aseta_vedenpinta_seuraavaan_merkkiin()


## Asettaa vedenpinnan seuraavan merkin korkeudelle.
func aseta_vedenpinta_seuraavaan_merkkiin():
	# Ei aseteta vedenpintaa seuraavaan merkkiin, jos merkkejä ei ole
	if not vedenpinnan_merkit:
		return

	aseta_vedenpinta_merkkiin(vedenpinnan_merkit[seuraava_merkki])
	seuraava_merkki = (seuraava_merkki + 1) % vedenpinnan_merkit.size()


## Asettaa vedenpinnan annetun merkin korkeudelle
## Jos funktiota kutsutaan ilman merkki-parametria,
## vedenpinta asettuu ensimmäisen Marker2D-noden korkeudelle
func aseta_vedenpinta_merkkiin(merkki: Marker2D = ensimmainen_merkki):
	if vedenpinnan_merkit.size() == 0:
		print_debug("Vesi2D:lla (%s) ei ole Marker2D-nodeja lapsina, skipataan" % self.name)
		return

	var korkeus = (vedenpohja - clamp(merkki.global_position.y, vedenpinta, vedenpohja))
	
	aseta_vedenpinta(korkeus / (vedenpohja - vedenpinta))


## Asettaa vedenpinnan, välillä nollasta yhteen.
## Nollaan asetettuna vesialue on matalimmillaan, yhteen asetettuna korkeimmillaan.
## Vesialueen korkein mahdollinen piste määräytyy CollisionShape2D-nodejen korkeimman pisteen mukaan.
func aseta_vedenpinta(korkeus: float):
	korkeus = clamp(korkeus, 0, 1)
	
	# Vedenpinnan uusi y-koordinaatti, johon jokainen CollisionShape2D pyrkii siirtymään
	var uusi_vedenpinta = vedenpohja - (vedenpohja - vedenpinta) * korkeus
	
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(transition_type).set_ease(ease_type)

	for obj in collision_shapet:
		var obj_vedenpinta = uusi_vedenpinta
		if maksimikorkeus_collisionshapella:
			obj_vedenpinta = max(obj["vedenpinta"], uusi_vedenpinta)
		var obj_vedenpohja = obj["vedenpohja"]

		var uusi_korkeus = obj_vedenpohja - obj_vedenpinta
		var uusi_sijainti = obj_vedenpohja - (obj_vedenpohja - obj_vedenpinta) * 0.5

		tween.tween_property(obj["collision_shape"], "shape:size:y", uusi_korkeus, animaation_kesto)
		tween.tween_property(obj["collision_shape"], "global_position:y", uusi_sijainti, animaation_kesto)

		tween.tween_property(obj["sprite2d"], "global_position:y", uusi_sijainti, animaation_kesto)
		tween.tween_property(obj["sprite2d"], "scale:y", uusi_korkeus, animaation_kesto)

		tween.tween_property(obj["pointlight"], "global_position:y", uusi_sijainti, animaation_kesto)
		tween.tween_property(obj["pointlight"], "scale:y", uusi_korkeus, animaation_kesto)

		for lumme in obj["lumpeet"]:
			tween.tween_property(lumme, "global_position:y", obj_vedenpinta, animaation_kesto)
