extends CollisionShape2D
class_name Vesialue
## Vesi2D-noden lapseksi asetettava vesialue.


var tween: Tween
var vedenpohja_y = 0
var vedenpinta_y = 0
## Sisältääkö Vesialue vedenpintaa, jolloin se voi nousta alustavaa vedenpintaansa korkeammalle
var sisaltaa_vedenpintaa = false
## Veden shaderi
var vesi_shader = preload("res://tres-tiedostot/vesi.tres")
## Vedenpinnan shaderi
var vedenpinta_shader = preload("res://tres-tiedostot/vedenpinta.tres")
## Veden valo
var vesi_pointlight = preload("res://scenet/vesi2d_pointlight2d.tscn")
## Vesialueen lumpeet
var lumpeet = []
var sprite2d = null
var pointlight = null
## Sivuuttaako vesialue vedenpinnan muuttumisen
@export var paikallaan = false


# Asettaa vesialueen muuttujat
func _ready() -> void:
	# Jos vesialueelle ei ole asetettu RectangleShape2D:ta, poistetaan vesialue.
	if not shape is RectangleShape2D:
		print_debug("Vesialueella %s ei ole RectangleShape2D:ta, poistetaan..." % self.get_path())
		self.queue_free()
	
	# Asetetaan vedenpohjan ja vedenpinnan y-koordinaatit
	vedenpohja_y = self.global_position.y + shape.size.y * 0.5
	vedenpinta_y = self.global_position.y - shape.size.y * 0.5

	# Lisätään Sprite2D lapseksi, joka sisältää vesishaderin
	sprite2d = Sprite2D.new()
	var canvas_texture = CanvasTexture.new()
	pointlight = vesi_pointlight.instantiate()

	# Asetetaan Sprite2D:n sijainti ja koko vastaamaan CollisionShape2D:ta
	# ja asetetaan sille tyhjä CanvasTexture
	sprite2d.set_texture(canvas_texture)
	sprite2d.set_region_enabled(true)
	sprite2d.set_region_rect(Rect2(0, 0, self.shape.size.x, self.shape.size.y))
	sprite2d.light_mask = 0
	sprite2d.set_z_index(20)
	#sprite2d.position = self.position

	pointlight.scale = self.shape.size
	#pointlight.position = self.position

	self.add_child(sprite2d)
	self.add_child(pointlight)

	# Käydään läpi vesialueen lumpeet ja lisätään ne taulukkoon
	for lapsi in self.get_children():
		if lapsi is Lumme:
			lapsi.global_position.y = vedenpinta_y
			lumpeet.append(lapsi)


## Asettaa vedenpinnan annettuun y-koordinaattiin.
func aseta_vedenpinta(y, animaation_kesto):
	if paikallaan:
		return

	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR)

	y = min(y, vedenpohja_y)
	if not sisaltaa_vedenpintaa:
		y = max(y, vedenpinta_y)
	
	var uusi_korkeus = vedenpohja_y - y
	var uusi_sijainti = vedenpohja_y - uusi_korkeus * 0.5

	tween.tween_property(self, "shape:size:y", uusi_korkeus, animaation_kesto)
	tween.tween_property(self, "global_position:y", uusi_sijainti, animaation_kesto)

	#tween.tween_property(sprite2d, "global_position:y", uusi_sijainti, animaation_kesto)
	tween.tween_property(sprite2d, "region_rect:size:y", uusi_korkeus, animaation_kesto)

	#tween.tween_property(pointlight, "global_position:y", uusi_sijainti, animaation_kesto)
	tween.tween_property(pointlight, "scale:y", uusi_korkeus, animaation_kesto)

	for lumme in lumpeet:
		tween.tween_property(lumme, "global_position:y", y, animaation_kesto)
	
	tween.set_parallel(uusi_korkeus >= 1)
	tween.tween_callback(func():
		self.visible = uusi_korkeus >= 1
		self.disabled = uusi_korkeus < 1
	)


## Asettaa sisaltaa_vedenpintaa-muuttujan ja päivittää shaderin parametrin
func set_sisaltaa_vedenpintaa(_sisaltaa_vedenpintaa):
	self.sisaltaa_vedenpintaa = _sisaltaa_vedenpintaa
	if sisaltaa_vedenpintaa:
		sprite2d.set_material(vedenpinta_shader)
	else:
		sprite2d.set_material(vesi_shader)


## Palauttaa, osuuko annettu Vesialue tämän Vesialue-noden vedenpintaan.
func osuu_vedenpintaan(vesialue: Vesialue) -> bool:
	if self == vesialue:
		return false

	var _rect = self.shape.get_rect()
	var rect1 = Rect2(
		_rect.position + self.position,
		_rect.size
	)
	_rect = vesialue.shape.get_rect()
	var rect2 = Rect2(
		_rect.position + vesialue.position,
		_rect.size
	)

	for i in range(3):
		var sijainti = Vector2(rect1.position.x + rect1.size.x * 0.2 + rect1.size.x * (i / 2.0) * 0.6, rect1.position.y)
		if rect2.has_point(sijainti):
			return true
	return false
