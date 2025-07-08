extends Perhonen
class_name PerhonenAmpuja
## Alustava skripti ampuvalle perhoselle.
## TODO: Korjaa perhosen teleporttaus, jos polulle palatessa pelaaja tulee takaisin sen alueelle


## (Testausta varten)
## Asettaa pelin alkaessa kohteen polunetsinnälle.
@export var kohde: Marker2D

## Ajastin, kuinka tiheästi perhonen päivittää kohteen pelaajaan
@onready var kohteen_asetus_timer = $KohteenAsetusTimer
## Seuraako perhonen pelaajaa vai ei
var seuraa_pelaajaa = false
## Onko perhonen palaamassa polulle pelaajaa seurattuaan
var palaamassa_polulle = false
## Viimeisin sijainti, jossa perhonen oli polulta lähtiessään
var viimeisin_sijainti_polulla = null
## Kuinka pitkään perhosella kestää palata polulleen
const PALUUKESTO = 0.01

var pelaaja = null

var tween = null

## Perhosen hp
var hp = 3


func _physics_process(delta: float) -> void:
	if palaamassa_polulle:
		return
	if seuraa_pelaajaa:
		polunetsija.liikuta_vanhempaa(delta)
	else:
		super.path2d_liikkuminen(delta)


## Kun pelaaja poistuu perhosen etäisyydeltä
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		seuraa_pelaajaa = false
		pelaaja = body
		kohteen_asetus_timer.stop()
		palaamassa_polulle = true

		if tween:
			tween.kill()
		tween = get_tree().root.create_tween()
		tween.tween_property(
			self, "global_position", viimeisin_sijainti_polulla,
			viimeisin_sijainti_polulla.distance_to(self.global_position) * PALUUKESTO
		)
		tween.tween_callback(func():
			palaamassa_polulle = false
		)


## Kun pelaaja tulee lähelle perhosta
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja and polunetsija:
		seuraa_pelaajaa = true
		viimeisin_sijainti_polulla = global_position
		palaamassa_polulle = false
		pelaaja = body
		polunetsija.aseta_kohde(body.global_position)
		kohteen_asetus_timer.start()


## Asetetaan uusi kohde pelaajaan
func _on_kohteen_asetus_timer_timeout() -> void:
	if seuraa_pelaajaa and pelaaja:
		polunetsija.aseta_kohde(pelaaja.global_position)
	else:
		kohteen_asetus_timer.stop()


## Vähennä hp, jos perhoseen osuu valopallo
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("valopallo"):
		hp -= 1
		if hp <= 0:
			queue_free()
