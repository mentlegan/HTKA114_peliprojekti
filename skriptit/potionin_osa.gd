extends Area2D
class_name PotioninOsa
## Potionin osa, jonka pelaaja voi kerätä. Kuuluu ryhmään potionin_osa.
## Keräämisen jälkeen potion poistuu sekä scenestä että ryhmästä.
## Kun ryhmässä ei ole enää jäseniä, kaikki osat on kerätty.


## Keräysanimaation kesto
const ANIMAATION_KESTO = 2
## Valo
@onready var pointlight = $PointLight2D


func _ready():
	# Pelin alussa lisää itsensä potionin_osa-ryhmään
	add_to_group("potionin_osa")


## Kerää ja tuhoaa osan. Palauttaa, kuinka monta osaa on vielä keräämättä.
func keraa() -> int:
	# Ei kerätä uudestaan, kun keräämisanimaatio on käynnissä
	remove_from_group("potionin_osa")

	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0, ANIMAATION_KESTO)
	tween.tween_property(self, "global_position:y", global_position.y - 40, ANIMAATION_KESTO)
	tween.tween_property(pointlight, "energy", 0, ANIMAATION_KESTO)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

	return get_tree().get_nodes_in_group("potionin_osa").size()
