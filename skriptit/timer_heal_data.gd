extends Resource
class_name TimerHealData
## Resurssi, joka pitää sisällään healaavan timerin ominaisuudet
## Juuso 27.1.2025

## Heal maara
@export var heal_maara: int = 1

## Ajoitukset
@export var lataus_aika: float = 2 ## Aika, jonka verran lataa healia
@export var burst_aika: float = 0.4 ## Aika, jonka aikana "räjähtää"
@export var heal_ennen_burst_loppu: float = 0.1 ## Aika, jota ennen burstin loppua heal tapahtuu
@export var palautumis_aika: float = 0.75 ## Aika, jonka aikana palaa alkutilaan

## Heal timeout, riippuvainen tweenausefektin ajoista
var heal_timeout: float ## Kun luodaan, on aina sama, seuraavilla kerroilla hieman pidempi

## Alustaa resurssin tarvittavat muuttujat
func _init() -> void:
	heal_timeout = lataus_aika + burst_aika - heal_ennen_burst_loppu


## Palauttaa ajan, joka toimii timerin aikana muulloin kuin ensimmäisellä heal kerralla
func get_pidempi_timeout() -> float:
	return heal_timeout + palautumis_aika + heal_ennen_burst_loppu
