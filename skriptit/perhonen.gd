extends Area2D
class_name Perhonen

## Perhosen Path2D-node
var path2d: Path2D = null
## Perhosen PathFollow2D-node
var path_follow_2d: PathFollow2D = PathFollow2D.new()

## Perhosen animaatio
@onready var animaatio: AnimatedSprite2D = $AnimatedSprite2D
## Perhosen äänet
@onready var audio_perhonen: AudioStreamPlayer2D = $AudioPerhonen
@onready var aanen_ajastin = Timer.new()
# Perhosen mahdollinen polunetsijä
var polunetsija = null
# Liikkumiseen käytettävä callable
var liikkumis_callable = null
## Perhosen nopeus
@export var nopeus: float = 80
## Perhosen edeltävän framen x-koordinaatti
var edeltava_x = position.x
## Perhosen tämänhetkinen etäisyys reitillä. Liukuluku, 0..1 välissä
var etaisyys = 0
## Perhosen aloituspiste, joka asetetaan _ready()-kutsun aikana
var aloituspiste = global_position
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
	
	# Etsitään perhosen path2d ja polunetsijä lapsi-nodeista, jos jompikumpi on
	# olemassa
	for lapsi in self.get_children():
		if lapsi is Path2D:
			path2d = lapsi
		if lapsi is Polunetsija:
			polunetsija = lapsi
	
	# Lisätään Path2D:n lapseksi PathFollow2D ja muokataan aloituspistettä
	if path2d:
		path2d.add_child(path_follow_2d)
		aloituspiste = global_position + path2d.position
		
		# Asetetaan perhosen reitin pituus
		var curve2d: Curve2D = path2d.get_curve()
		if curve2d:
			reitin_pituus = max(1, curve2d.get_baked_length())
		
		# Asetetaan liikkumiseen käytettävä callable oikein
		liikkumis_callable = Callable(self, "path2d_liikkuminen")
	elif polunetsija:
		# Jos lapsena on Path2D:n sijaan Polunetsija, käytetään sen funktiota
		# liikkumiseen
		liikkumis_callable = Callable(polunetsija, "liikuta_vanhempaa")


## Kutsutaan, kun aanen_ajastin aika menee loppuun
func on_aanen_ajastin_timeout():
	audio_perhonen.play()
	aanen_ajastin.start(randf_range(1.5, 3.0))


## Laskee etäisyyden
func laske_etaisyys(delta: float) -> void:
	etaisyys += (delta * nopeus) / reitin_pituus


## Liikkuu lapsena olevan Path2D-noden reitillä
func path2d_liikkuminen(delta):
	laske_etaisyys(delta)
	# Kuljetetaan pathfollow2d-nodea reitillä eteenpäin
	path_follow_2d.set_progress_ratio(etaisyys)
	
	# Käännetään perhonen suunnan mukaan
	animaatio.set_flip_h(edeltava_x < path_follow_2d.position.x)
	
	# Asetetaan nykyisen framen x-koordinaatti seuraavaa framea varten
	edeltava_x = path_follow_2d.position.x
	
	# Siirretään perhonen pathfollow2d:n koordinaatteihin
	self.global_position.x = aloituspiste.x + path_follow_2d.position.x
	self.global_position.y = aloituspiste.y + path_follow_2d.position.y


## Kutsutaan joka framella
func _physics_process(delta: float) -> void:
	# Liikutaan callablen avulla
	if liikkumis_callable:
		liikkumis_callable.call(delta)
