extends Perhonen
class_name PerhonenAmpuja
## Alustava skripti ampuvalle perhoselle.
## TODO: Korjaa perhosen teleporttaus, jos polulle palatessa pelaaja tulee takaisin sen alueelle
## TODO: Tuki navigoitavien alueiden valitsemiselle
## TODO: Käytä polunetsijää myös polulle palatessa
## TODO: Älä jää NavigationRegionin reunalle paikalleen jos pelaaja on sen ulkopuolella, vaan lähde takaisin polulle
## TODO: Jonkinlainen state machine physics processiin


## (Testausta varten)
## Asettaa pelin alkaessa kohteen polunetsinnälle.
@export var kohde: Marker2D

@onready var sprite = $AnimatedSprite2D

var happo = preload("res://scenet/happo.tscn")
## Ajastin, kuinka tiheästi perhonen pyrkii ampumaan pelaajaa
@onready var ampumisajastin = $AmpumisAjastin
## Ajastin, kuinka nopeasti hapon peittämänä perhonen palautuu normaalitilaan
@onready var happoajastin = $HappoAjastin
## Ajastin, kuinka tiheästi perhonen päivittää kohteen pelaajaan
@onready var kohteen_asetus_timer = $KohteenAsetusTimer
## Raycast, jolla perhonen ei lähde jahtaamaan pelaajaa seinien läpi
@onready var raycast = $RayCast2D
## Seuraako perhonen pelaajaa vai ei
var seuraa_pelaajaa = false
## Onko perhonen palaamassa polulle pelaajaa seurattuaan
var palaamassa_polulle = false
## Viimeisin sijainti, jossa perhonen oli polulta lähtiessään
var viimeisin_sijainti_polulla = null
## Onko perhonen liian lähellä pelaajaa sitä seuratessaan
var liian_lahella = false
## Kuinka pitkään perhosella kestää palata polulleen
const PALUUKESTO = 0.01

var pelaaja = null

var tween = null

## Perhosen hp
var hp = 3


func _physics_process(delta: float) -> void:
	if palaamassa_polulle or (seuraa_pelaajaa and liian_lahella):
		return
	if seuraa_pelaajaa:
		polunetsija.liikuta_vanhempaa(delta)
	elif pelaaja and nakee_pelaajan():
		aloita_jahtaaminen()
	else:
		super.path2d_liikkuminen(delta)


## Kun pelaaja poistuu perhosen etäisyydeltä
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		seuraa_pelaajaa = false
		pelaaja = null
		kohteen_asetus_timer.stop()
		palaamassa_polulle = true

		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(
			self, "global_position", viimeisin_sijainti_polulla,
			viimeisin_sijainti_polulla.distance_to(self.global_position) * PALUUKESTO
		)
		tween.tween_callback(func():
			palaamassa_polulle = false
		)


## Palauttaa, näkeekö perhonen pelaajan vai onko seinää välissä
func nakee_pelaajan() -> bool:
	viimeisin_sijainti_polulla = global_position
	raycast.set_target_position(pelaaja.global_position - self.global_position)
	raycast.force_raycast_update()
	return not raycast.is_colliding()


## Aloittaa pelaajan jahtaamisen, jos perhonen näkee pelaajan
func aloita_jahtaaminen():
	seuraa_pelaajaa = true
	palaamassa_polulle = false
	polunetsija.aseta_kohde(pelaaja.global_position)
	kohteen_asetus_timer.start()


## Ampuu pelaajaa kohti happoa
func ammu():
	# Jos pelaaja on jo sisemmän alueen ulkopuolella, ei enää ammuta
	if not pelaaja:
		ampumisajastin.stop()
		return

	if not nakee_pelaajan():
		return

	var pallo = happo.instantiate()
	pallo.global_position = self.global_position
	pallo.velocity = self.global_position.direction_to(pelaaja.global_position)
	pallo.perhonen = self
	get_tree().root.call_deferred("add_child", pallo)


## Aloittaa pelaajan ampumisen
func aloita_ampuminen():
	# Aloitetaan ampuminen pelkästään, jos ajastin on kerennyt pysähtyä.
	if ampumisajastin.get_time_left() < 0.01:
		ammu()
	ampumisajastin.start()


## Kun pelaaja tulee lähelle perhosta
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja and polunetsija:
		pelaaja = body
		aloita_ampuminen()
		if nakee_pelaajan():
			aloita_jahtaaminen()


## Asetetaan uusi kohde pelaajaan
func _on_kohteen_asetus_timer_timeout() -> void:
	if seuraa_pelaajaa and pelaaja:
		polunetsija.aseta_kohde(pelaaja.global_position)
	else:
		kohteen_asetus_timer.stop()


## Asetetaan perhonen hapon peittämäksi, jos osutaan kimmotettuun happoon
func _on_hitbox_body_entered(body) -> void:
	if body is Happo:
		if body.kimmotettu:
			happoajastin.start()
			sprite.modulate = Color.YELLOW
			body.queue_free()


## Vähennä hp, jos perhoseen osuu valopallo
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("valopallo"):
		hp -= 1
		if hp <= 0 or not happoajastin.is_stopped():
			queue_free()


## Happoajastimen loppuessa palautetaan normaali väri spritelle
func _on_happo_ajastin_timeout() -> void:
	print("TIMEOUT")
	sprite.modulate = Color.WHITE


## Pelaaja on tarpeeksi kaukana jahtaamisdeadzonelta poistuessaan
func _on_jahtaamis_deadzone_body_exited(body):
	if body is Pelaaja:
		liian_lahella = false


## Pelaaja on liian lähellä jahtaamisdeadzonelle tullessaan
func _on_jahtaamis_deadzone_body_entered(body):
	if body is Pelaaja:
		liian_lahella = true