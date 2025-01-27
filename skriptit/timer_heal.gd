extends Node
class_name TimerHeal
## Node, joka toimii healaavan timerin pohjana
## healaa pelaajaa, kun skohde asetetaan timeri luotaessa
## Juuso 27.1.2025

@export var data: TimerHealData

@onready var timer: Timer = $Timer

var pelaaja: Pelaaja
var ensimmainen_heal: bool = true

func _ready() -> void:
	alusta_timer()


func alusta_timer() -> void:
	timer.wait_time = data.heal_timeout
	timer.start()
	print_debug(self.name, " LUOTU AJASTIN ", self.name)


## Tällä hetkellä vain pelaaja
func aseta_kohde(_pelaaja: Pelaaja) -> void:
	pelaaja = _pelaaja


## Nimi scenetreehen lisäämisen jälkeen, ettei muuta automaattisesti muotoon @Timer...
func aseta_nimi() -> void:
	self.name = "TimerHeal"


func _on_timer_timeout() -> void:
	pelaaja.saa_elamia(data.heal_maara)
	if ensimmainen_heal:
		ensimmainen_heal = false
		# Nyt pidempi cooldown palautumisajan takia
		timer.start(data.get_pidempi_timeout())


func tuhoa() -> void:
	print_debug(self.name, " TUHOTTU AJASTIN ", self.name)
	self.queue_free()
