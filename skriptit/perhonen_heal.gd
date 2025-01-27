extends Perhonen
class_name PerhonenHeal
## Healaava perhonen
## Juuso 27.1.2024

@export var timer_heal_node: PackedScene

@onready var plight_2d: PointLight2D = $PointLight2D

var timer_heal: TimerHeal

var aloitus_texture_scale: float
var tween: Tween

func _ready() -> void:
	super._ready()
	aloitus_texture_scale = plight_2d.texture_scale


## Luo ajastimen pelaajalle, joka kutsuu elama_regen funktiota
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		luo_heal_timer(body)
		heal_efekti()


func luo_heal_timer(pelaaja: Pelaaja) -> void:
	timer_heal = timer_heal_node.instantiate()
	timer_heal.aseta_kohde(pelaaja)
	pelaaja.add_child(timer_heal)
	timer_heal.aseta_nimi()


func heal_efekti() -> void:
	if tween:
		tween.kill()
	# Muutos valon texture scaleen
	var muutos_lataus: float = 0.4
	var muutos_burst: float = 0.45
	# Ideana tässä efektissä on, että latautuminen olisi aluksi nopeampaa, lopuksi hidasta
	# Burst aluksi hitaampi, lopuksi nopeampi
	# Palautuminen tasaista
	tween = create_tween().set_loops(0)
	tween.tween_property(plight_2d, "texture_scale", 
						aloitus_texture_scale - muutos_lataus, 
						timer_heal.data.lataus_aika).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(plight_2d, "texture_scale", 
						aloitus_texture_scale + muutos_burst, 
						timer_heal.data.burst_aika).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	# TODO: mm. partikkelit, ääni
	tween.tween_property(plight_2d, "texture_scale", 
						aloitus_texture_scale, 
						timer_heal.data.palautumis_aika).set_trans(Tween.TRANS_LINEAR)


## Poistetaan ajastin, kun poistutaan alueelta
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		if tween:
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(plight_2d, "texture_scale", aloitus_texture_scale, timer_heal.data.palautumis_aika)
		if timer_heal:
			timer_heal.tuhoa()
		else:
			printerr("EI LÖYTYNYT AJASTINTA", self.name)
