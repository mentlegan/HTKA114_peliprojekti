## Polunetsijä-node, joka liikuttaa vanhempaa NavigationRegion2D-nodejen sisällä.
## Kohde asetetaan aseta_kohde()-funktiolla, tai (testatessa) asettamalla
## Marker2D-node PerhonenCombat-noden Kohde-muuttujaan editorissa.
extends NavigationAgent2D
class_name Polunetsija


## Polunetsijän nopeus. Korvataan vanhemman nopeudella, jos "nopeus"-muuttuja
## on olemassa.
@onready var nopeus = 100.0
var vanhempi = null


func _ready():
	vanhempi = get_parent()

	if "nopeus" in vanhempi:
		nopeus = vanhempi.nopeus
	else:
		print_debug("VAROITUS: Polunetsijän vanhemmalla %s ei ole 'nopeus'-muuttujaa, käytetään oletusarvoa." % vanhempi.get_path())
	
	if vanhempi.kohde:
		aseta_kohde(vanhempi.kohde.global_position)


## Asettaa polunetsijälle kohteen globaalina koordinaattina.
## Asettaa tarvittaessa kohteen vastakkaiseen suuntaan.
func aseta_kohde(_global_position, poispain = false):
	if poispain:
		self.target_position = 2 * vanhempi.global_position - _global_position
	else:
		self.target_position = _global_position
	#print("Polunetsijän kohde asetettu: " + str(self.target_position))


## Liikkuu asetettua kohdetta päin, jos Polunetsijan vanhempi on
## NavigationRegion2D-noden sisällä.
## Palauttaa, onko navigaatio loppunut
func liikuta_vanhempaa(delta) -> bool:
	if self.is_navigation_finished():
		return true

	# Haetaan seuraava sijainti
	var seuraava_sijainti = self.get_next_path_position()
	# Asetetaan Polunetsijan vauhti
	velocity = vanhempi.global_position.direction_to(seuraava_sijainti) \
				* nopeus * delta
	# Liikutetaan vanhempaa
	vanhempi.position += self.get_velocity()
	return false
