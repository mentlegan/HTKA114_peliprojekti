extends Area2D
class_name Vesi2D
## Alue, jonka CollisionShape2D-nodeilla on vettä.
## Vedenpinta voidaan asettaa funktiolla aseta_vedenpinta(0..1) tai aseta_vedenpinta_merkkiin()


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


func _ready():
	# Etsitään vesialueen lapsista CollisionShape2D:t.
	for lapsi in get_children():
		if lapsi is CollisionShape2D:
			if lapsi.shape is RectangleShape2D:
				collision_shapet.append({
					"collision_shape": lapsi,
					"vedenpohja": lapsi.global_position.y + lapsi.shape.size.y * 0.5,
					"vedenpinta": lapsi.global_position.y - lapsi.shape.size.y * 0.5,
					"korkeus": lapsi.shape.size.y
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
	
	print("vedenpinta: %s" % vedenpinta)
	print("vedenpohja: %s" % vedenpohja)
	print("uusi_vedenpinta: %s" % uusi_vedenpinta)
	
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)

	for obj in collision_shapet:
		var obj_vedenpinta = max(obj["vedenpinta"], uusi_vedenpinta)
		var obj_vedenpohja = obj["vedenpohja"]

		var uusi_korkeus = obj_vedenpohja - obj_vedenpinta
		var uusi_sijainti = obj_vedenpohja - (obj_vedenpohja - obj_vedenpinta) * 0.5
		
		print("uusi_korkeus: %s" % uusi_korkeus)
		print("uusi_sijainti: %s" % uusi_sijainti)

		tween.tween_property(obj["collision_shape"], "shape:size:y", uusi_korkeus, 10)
		tween.tween_property(obj["collision_shape"], "global_position:y", uusi_sijainti, 10)
