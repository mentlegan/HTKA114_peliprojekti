## Paavo 14.3.2024
## TODO: tarkista: jos valonlahteet-taulukossa oleva node poistetaan scenetreestä, poistuuko se
## _on_area_exited()-kutsun kautta valonlahteet-taulukosta.
extends Area2D

signal siirrytty_valoon
signal siirrytty_varjoon

## Valonlähteet, joiden sisällä ollaan 
var valonlahteet = Array()
## RayCast valontarkistusta varten
@onready var raycast = $RayCast2D
## Totuusarvo valossa olemiselle
var valossa = false


func _physics_process(_delta):
	# Päivitetään valossa-muuttuja ja lähetetään tarvittaessa signaalit
	var aiemmin_valossa = valossa
	valossa = on_valossa()
	if aiemmin_valossa and not valossa:
		siirrytty_varjoon.emit()
	elif not aiemmin_valossa and valossa:
		siirrytty_valoon.emit()


## Palauttaa, onko node valossa.
func on_valossa():
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


## Kun Area2D-node lähtee, poistetaan se valonlahteet-taulukosta
func _on_area_exited(area):
	# Ei turhaan tarkisteta valonlahteet.has(area)-kutsulla, onko area2d jo taulukossa.
	# Poistetaan, jos sattuu olemaan.
	valonlahteet.erase(area)
