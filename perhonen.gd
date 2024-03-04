extends Area2D


# Perhosen PathFollow2D-node
var path_follow_2d = PathFollow2D.new()
# Perhosen Path2D-node
var path2d = null
# Perhosen animaatio
@onready var animaatio = $AnimatedSprite2D
# Perhosen nopeus
const NOPEUS = 0.1
# Perhosen edeltävän framen x-koordinaatti
var edeltava_x = position.x
# Perhosen tämänhetkinen etäisyys reitillä. Liukuluku, 0..1 välissä
var etaisyys = 0
# Perhosen aloituspiste, joka asetetaan _ready()-kutsun aikana
var aloituspiste = null


func _ready():
	# Käynnistetään perhosen animaatio
	animaatio.play()
	
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
	
	# Lisätään path2d:n lapseksi pathfollow-node
	if path2d:
		path2d.add_child(path_follow_2d)
	
	# Asetetaan perhosen aloituspiste
	aloituspiste = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Kuljetetaan pathfollow2d-nodea reitillä eteenpäin
	etaisyys += delta * NOPEUS
	path_follow_2d.set_progress_ratio(etaisyys)
	
	# Käännetään perhonen suunnan mukaan
	animaatio.set_flip_h(edeltava_x < path_follow_2d.position.x)
	
	# Asetetaan nykyisen framen x-koordinaatti seuraavaa framea varten
	edeltava_x = path_follow_2d.position.x
	
	# Siirretään perhonen pathfollow2d:n koordinaatteihin
	self.global_position.x = aloituspiste.x + path_follow_2d.position.x
	self.global_position.y = aloituspiste.y + path_follow_2d.position.y
