## Paavo 14.3.2024
## TODO: tarkista: jos valonlahteet-taulukossa oleva node poistetaan scenetreestä, poistuuko se
## _on_area_exited()-kutsun kautta valonlahteet-taulukosta.
##
## Node, joka lähettää signaalin sen siirtyessä valoon tai varjoon.
## Aseta ValonTarkistus-node SceneTreessä kyseistä toiminnallisuutta tarvitsevan
## noden lapseksi, esim Pelaaja-noden tapauksessa:
##
## Pelaaja
## |
## '-> ValonTarkistus
##     |
##     '-> CollisionShape2D    <- Aseta ValonTarkistuksen lapseksi myös CollisionShape2D.
##                                Valoa tarkistetaan pelkästään, kun kyseisellä alueella on
##                                valonlähteitä.
##
## ValonTarkistus lähettää signaalin, kun se siirtyy valoon tai varjoon.
## Jos CollisionShape2D:n sisällä olevan valonlähteen ja ValonTarkistus-noden
## välillä ei ole terrainia, ollaan valossa.
##
## Tarkoitus ei ole käyttää funktiota _on_valossa() valon tarkistamiseen, vaan
## kuunnella signaaleita siirrytty_valoon ja siirrytty_varjoon.
##
## Signaaleiden kuunteleminen onnistuu, kun inspectorin kautta yhdistetään signaalit
## toiminnallisuutta tarvitsevan vanhemman funktioihin: Valitaan SceneTreessä
## ValonTarkistus-node, valitaan Node-välilehti > Signals > valon_tarkistus.gd > siirrytty_valoon()/-varjoon()
##
## Tätä varten vanhemmalla on oltava funktiot, joissa on omaa toiminnallisuutta
## valoon tai varjoon siirtymiseen liittyen.
##
## Tarkoitus siis käyttää seuraavasti:
##
## Pelaaja  <---.
## |            |
## |  siirrytty_valoon/-varjoon -signaali
## |            |
## '-> ValonTarkistus
##     |
##     '-> CollisionShape2D
##
## Tarkoitus _ei_ole_ käyttää seuraavasti, vaikka tämä toimisi:
##
## Pelaaja  ----.
## |            |
## |     _on_valossa()-kutsu
## |            |
## |            V
## '-> ValonTarkistus
##     |
##     '-> CollisionShape2D

extends Area2D

signal siirrytty_valoon
signal siirrytty_varjoon

## Valonlähteet, joiden sisällä ollaan 
var valonlahteet = Array()
## RayCast valontarkistusta varten
@onready var raycast = $RayCast2D
## RemoteTransform2D vanhempien skaalauksen ja rotaation ohittamiseksi
@onready var remotetransform = $RemoteTransform2D
## Totuusarvo valossa olemiselle
var valossa = null


func _ready():
	# Siirretään raycast nykyisen scenen lapseksi
	self.remove_child(raycast)
	get_tree().get_current_scene().add_child.call_deferred(raycast)

	# Odotetaan, että raycast on lisätty nykyisen scenen lapseksi
	await Engine.get_main_loop().process_frame

	# Laitetaan RemoteTransform2D päivittämään raycastin sijaintia
	remotetransform.set_remote_node(raycast.get_path())


## Kutsutaan joka physics framella
func _physics_process(_delta):
	# Lähetetään tarvittaessa signaalit
	_laheta_signaalit()


## Päivittää valossa-muuttujan ja lähettää tarvittaessa signaalin siirrytty_varjoon tai siirrytty_valoon.
func _laheta_signaalit():
	var aiemmin_valossa = valossa
	valossa = _on_valossa()

	if valossa != aiemmin_valossa:
		if valossa:
			siirrytty_valoon.emit()
		else:
			siirrytty_varjoon.emit()


## Palauttaa, onko node valossa. Älä kutsu tätä funktiota erikseen, vaan kuuntele tämän noden lähettämiä signaaleita siirrytty_valoon ja siirrytty_varjoon.
func _on_valossa():
	# Käydään läpi valonlähteet, joiden sisällä ollaan
	for valonlahde in valonlahteet:
		# Tähdätään raycast valonlähteeseen päin
		raycast.set_target_position(
			valonlahde.global_position - raycast.global_position
		)
		
		# Päivitetään raycast sitä varten, että valonlähde olisi kerennyt muuttua saman framen aikana.
		# Vaikuttaa myös korjaavan bugin, jossa on_valossa palauttaa true yhden framen ajan,
		# kun astutaan varjossa valonlähteen sisälle.
		raycast.force_raycast_update()
		
		# Jos raycast ei osu mihinkään, ollaan valossa
		if not raycast.is_colliding():
			return true
	
	# Jos jokaisen valonlähteen edessä on terrainia, ei olla valossa
	return false


## Kun osutaan Area2D-nodeen, päivitetään valonlahteet-taulukko
func _on_area_entered(area):
	# Jos Area2D on valonlähde ja se ei ole valonlahteet-taulukossa, lisätään se sinne.
	if area.is_in_group("valonlahde") and not valonlahteet.has(area):
		valonlahteet.append(area)

		# Lähetetään samalla signaalit
		_laheta_signaalit()


## Kun Area2D-node lähtee, poistetaan se valonlahteet-taulukosta
func _on_area_exited(area):
	# Ei turhaan tarkisteta valonlahteet.has(area)-kutsulla, onko area2d jo taulukossa.
	# Poistetaan, jos sattuu olemaan.
	valonlahteet.erase(area)

	# Lähetetään samalla signaalit
	_laheta_signaalit()
