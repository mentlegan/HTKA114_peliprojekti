extends Area2D
class_name Vesi2D
## Alue, jonka CollisionShape2D-nodeilla on vettä.
## Vedenpinta voidaan asettaa funktiolla aseta_vedenpinta(0..1) tai aseta_vedenpinta_merkkiin()

## TODO: Käsittele päällekkäisten CollisionShape2D-nodejen aiheuttamat vesi-shaderin viat


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
## Vedenpinnan vaihtamisen Tween
var tween: Tween
## Veden shaderi
var vesi_shader = preload("res://tres-tiedostot/vesi.tres")


func _ready():
	# Etsitään vesialueen lapsista CollisionShape2D:t.
	for lapsi in get_children():
		if lapsi is CollisionShape2D:
			if lapsi.shape is RectangleShape2D:
				# Luodaan sprite2d, joka sisältää shaderin
				var sprite2d = Sprite2D.new()
				var canvas_texture = CanvasTexture.new()

				# Asetetaan Sprite2D:n sijainti ja koko vastaamaan CollisionShape2D:ta
				# ja asetetaan sille tyhjä CanvasTexture
				sprite2d.set_texture(canvas_texture)
				sprite2d.set_region_enabled(true)
				sprite2d.set_region_rect(Rect2(0, 0, 1, 1))
				sprite2d.set_z_index(10)
				sprite2d.set_material(vesi_shader)
				sprite2d.position = lapsi.position
				sprite2d.scale = lapsi.shape.size

				self.add_child(sprite2d)

				collision_shapet.append({
					"collision_shape": lapsi,
					"vedenpohja": lapsi.global_position.y + lapsi.shape.size.y * 0.5,
					"vedenpinta": lapsi.global_position.y - lapsi.shape.size.y * 0.5,
					"korkeus": lapsi.shape.size.y,
					"sprite2d": sprite2d
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
	
	aseta_vedenpinta_merkkiin()


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

	for obj in collision_shapet:
		var obj_vedenpinta = max(obj["vedenpinta"], uusi_vedenpinta)
		var obj_vedenpohja = obj["vedenpohja"]

		var uusi_korkeus = obj_vedenpohja - obj_vedenpinta
		var uusi_sijainti = obj_vedenpohja - (obj_vedenpohja - obj_vedenpinta) * 0.5

		tween.tween_property(obj["collision_shape"], "shape:size:y", uusi_korkeus, 10)
		tween.tween_property(obj["sprite2d"], "scale:y", uusi_korkeus, 10)
		tween.tween_property(obj["collision_shape"], "global_position:y", uusi_sijainti, 10)
		tween.tween_property(obj["sprite2d"], "global_position:y", uusi_sijainti, 10)
