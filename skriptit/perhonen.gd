extends Area2D
class_name Perhonen

## Perhosen Path2D-node
var path2d: Path2D = null
## Perhosen PathFollow2D-node
var path_follow_2d: PathFollow2D = PathFollow2D.new()

## Perhosen animaatio
@onready var animaatio = $AnimatedSprite2D
## Perhosen äänet
@onready var audio_perhonen = $AudioPerhonen
@onready var aanen_ajastin = Timer.new()
## Perhosen nopeus
@export var nopeus: int = 80
## Perhosen edeltävän framen x-koordinaatti
var edeltava_x = position.x
## Perhosen tämänhetkinen etäisyys reitillä. Liukuluku, 0..1 välissä
var etaisyys = 0
## Perhosen aloituspiste, joka asetetaan _ready()-kutsun aikana
var aloituspiste = null
## Perhosen reitin pituus, min 1
var reitin_pituus = 1


## Ready kutsutaan scenen avaamisessa
func _ready():
	# Käynnistetään perhosen animaatio
	animaatio.play()
	# Käynnistetään äänen ajastin
	self.add_child(aanen_ajastin)
	aanen_ajastin.timeout.connect(on_aanen_ajastin_timeout)
	aanen_ajastin.start()
	
	# Etsitään perhosen path2d lapsi-nodeista, jos sellainen on olemassa
	var path2d_jo_lapsena = false
	for lapsi in self.get_children():
		if lapsi is Path2D:
			path2d_jo_lapsena = true
			path2d = lapsi
			break
	
	# Jos Path2D-nodea ei ole asetettu editorissa, lisätään tyhjä Path2D lapseksi
	if not path2d_jo_lapsena:
		path2d = Path2D.new()
		self.add_child(path2d)
	
	# Lisätään Path2D:n lapseksi PathFollow2D
	path2d.add_child(path_follow_2d)
	
	# Asetetaan perhosen aloituspiste
	aloituspiste = global_position + path2d.position

	# Asetetaan perhosen reitin pituus
	var curve2d = path2d.get_curve()
	if curve2d:
		reitin_pituus = max(1, path2d.get_curve().get_baked_length())
	else:
		reitin_pituus = 1


## Kutsutaan kun aanen_ajastin aika menee loppuun
func on_aanen_ajastin_timeout():
	audio_perhonen.play()
	aanen_ajastin.start(randf_range(1.5, 3.0))


## Kutsutaan joka framella
func _physics_process(delta: float) -> void:
	# Kuljetetaan pathfollow2d-nodea reitillä eteenpäin
	etaisyys += (delta * nopeus) / reitin_pituus
	path_follow_2d.set_progress_ratio(etaisyys)
	
	# Käännetään perhonen suunnan mukaan
	animaatio.set_flip_h(edeltava_x < path_follow_2d.position.x)
	
	# Asetetaan nykyisen framen x-koordinaatti seuraavaa framea varten
	edeltava_x = path_follow_2d.position.x
	
	# Siirretään perhonen pathfollow2d:n koordinaatteihin
	self.global_position.x = aloituspiste.x + path_follow_2d.position.x
	self.global_position.y = aloituspiste.y + path_follow_2d.position.y
