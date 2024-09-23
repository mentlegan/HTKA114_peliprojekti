extends Node
class_name IlluusionVaihtaja
## Illuusio-node, joka päivittää veteen siirtyessä illuusiosta koituvat muutokset vanhemmalle.
## Tätä nodea ei voi käyttää sellaisenaan. On luotava uusi node, jonka skripti alkaa rivillä
## 'extends IlluusionVaihtaja'. Uuden IlluusionVaihtaja-variantin on toteutettava pelkästään
## funktio 'vaihda_illuusio(pelaaja_vedessa)'. Ks. illuusion_vaihtaja_visible.gd ja -tscn.
##
## IlluusionVaihtaja[Visible/Flip/jne] on asetettava sen noden alle,
## johon halutaan IlluusionVaihtajalla vaikuttaa. Esim. illuusion_vaihtaja_flip
## osaa kääntää Sprite2D:n vaakasuunnassa.
# Juuso 23.9.2024


## Käännetäänkö vaihtajan tila
@export var invert = false

## Lisätään illuusio-node ryhmään.
func _ready():
	add_to_group("illuusio")

	# Pelaaja ei heti tason alkaessa ole vedessä, joten päivitetään illuusion tila.
	#vaihda_illuusio(invert)
	# Kutsutaan aina falsena, sillä pelaaja ei ole ikinä vedessä alussa
	vaihda_illuusio(false)


## Tarkistaa, onko node samassa tasossa kuin pelaaja
func samassa_tasossa_kuin_pelaaja():
	return Globaali.samassa_tasossa_kuin_pelaaja(get_parent())


## Uudelleenkirjoitettava funktio, jota kutsumalla illuusion muutos tulee näkyviin.
func vaihda_illuusio(_pelaaja_vedessa: bool):
	pass


## Vaihtaa illuusion jos pelaaja on samassa tasossa noden kanssa.
func vaihda_illuusio_samassa_tasossa(pelaaja_vedessa: bool):
	if samassa_tasossa_kuin_pelaaja():
		vaihda_illuusio(pelaaja_vedessa != invert)
