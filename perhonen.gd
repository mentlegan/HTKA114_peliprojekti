extends Path2D


# Perhosen PathFollow2D-node
@onready var path_follow_2d = $PathFollow2D
# Perhosen animaatio
@onready var animaatio = $PathFollow2D/AnimatedSprite2D
# Perhosen nopeus
const NOPEUS = 0.1
# Perhosen edeltävän framen x-koordinaatti
var edeltava_x = position.x
# Perhosen tämänhetkinen etäisyys reitillä. Liukuluku, 0..1 välissä
var etaisyys = 0


func _ready():
	# Käynnistetään perhosen animaatio
	animaatio.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Kuljetetaan perhosta reitillä eteenpäin
	etaisyys += delta * NOPEUS
	path_follow_2d.set_progress_ratio(etaisyys)
	
	# Käännetään perhonen suunnan mukaan
	animaatio.set_flip_h(edeltava_x < path_follow_2d.position.x)
	
	# Asetetaan nykyisen framen x-koordinaatti seuraavaa framea varten
	edeltava_x = path_follow_2d.position.x
