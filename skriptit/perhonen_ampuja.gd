extends Perhonen
class_name PerhonenAmpuja
## Alustava skripti ampuvalle perhoselle.


## (Testausta varten)
## Asettaa pelin alkaessa kohteen polunetsinnälle.
@export var kohde: Marker2D

## Ajastin, kuinka tiheästi perhonen päivittää kohteen pelaajaan
@onready var kohteen_asetus_timer = $KohteenAsetusTimer
## Seuraako perhonen pelaajaa vai ei
var seuraa_pelaajaa = false

var pelaaja = null

## Perhosen hp
var hp = 3


func _physics_process(delta: float) -> void:
	if seuraa_pelaajaa:
		super._physics_process(delta)


## Kun pelaaja poistuu perhosen etäisyydeltä
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		seuraa_pelaajaa = false
		pelaaja = body
		kohteen_asetus_timer.stop()


## Kun pelaaja tulee lähelle perhosta
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja and polunetsija:
		seuraa_pelaajaa = true
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
