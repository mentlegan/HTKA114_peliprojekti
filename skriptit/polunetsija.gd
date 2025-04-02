## Polunetsijä-node, joka liikuttaa vanhempaa NavigationRegion2D-nodejen sisällä.
## Kohde asetetaan aseta_kohde()-funktiolla, tai (testatessa) asettamalla
## "Marker2D"-node Polunetsijan lapseksi.
extends NavigationAgent2D
class_name Polunetsija


## Polunetsijän nopeus. Korvataan vanhemman nopeudella, jos "nopeus"-muuttuja
## on olemassa vanhemmalla.
@onready var nopeus = 100.0
var vanhempi = null


func _ready():
    vanhempi = get_parent()

    if "nopeus" in vanhempi:
        nopeus = vanhempi.nopeus
    else:
        print_debug("VAROITUS: Polunetsijän vanhemmalla %s ei ole 'nopeus'-muuttujaa, käytetään oletusarvoa." % vanhempi.get_path())
    
    for lapsi in self.get_children():
        if lapsi is Marker2D:
            aseta_kohde(lapsi.global_position)
            break
    


## Asettaa polunetsijälle kohteen globaalina koordinaattina.
func aseta_kohde(_global_position):
    self.target_position = _global_position
    print("Kohde asetettu: " + str(self.target_position))


## Liikkuu asetettua kohdetta päin, jos Polunetsijan vanhempi on
## NavigationRegion2D-noden sisällä.
func liikuta_vanhempaa(delta):
    if self.is_navigation_finished():
        return

    # Haetaan seuraava sijainti
    var seuraava_sijainti = self.get_next_path_position()
    # Asetetaan Polunetsijan vauhti
    velocity = vanhempi.global_position.direction_to(seuraava_sijainti) \
                * nopeus * delta
    # Liikutetaan vanhempaa
    vanhempi.position += self.get_velocity()