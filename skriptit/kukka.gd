## Juuso 22.3.2024
## Paavo 18.4.2024
## Kukkien ominaisuudet luonnossa
## TODO: Vähemmän surkea toteutus Area2D:ssa CollisionShape2D:n poistamiseen

extends Area2D

## Kukan nodet
@onready var huilu_ajastin = $HuiluAjastin
@onready var kerays_cooldown = $Timer

@onready var area = $Area2D
@onready var point_light = $Area2D/PointLight2D
@onready var collision_shape = $Area2D/CollisionShape2D

@onready var partikkelit = $CPUParticles2D

## Muuttuja sille, onko valo asetettu päälle valopallolla
var valo_paalla_pysyvasti = false
## Cooldownia varten
var voiko_kerata = true

## Tween kukan animaatiota varten
var tween: Tween


## Asetetaan ajastimien timeout-funktiot ja valon tekstuuri
func _ready():
	point_light.set_energy(0)
	# Yhdistetään ajastimet huilun ominaisuuksilta palautumiseen
	huilu_ajastin.timeout.connect(sulje_valo)
	
	partikkelit.one_shot = true
	partikkelit.emitting = false
	
	kerays_cooldown.timeout.connect(vaihda_kerays)


func aloita_kerays():
	kerays_cooldown.start()
	voiko_kerata = false


func vaihda_kerays():
	voiko_kerata = true


func aloita_animaatio(skaala, valon_energia, kesto):
	# Lopetetaan aiempi tween, jos sellainen on olemassa
	if tween:
		tween.kill()
	
	# Aloitetaan animaatio
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(point_light, "texture_scale", skaala, kesto)
	tween.tween_property(point_light, "energy", valon_energia, kesto)
	tween.tween_property(collision_shape, "scale", Vector2(skaala, skaala), kesto)


## Aloittaa animaation / indikaation keräämiselle
func aloita_kerays_animaatio():
	partikkelit.emitting = true


## Sulkee kukan valon
func sulje_valo():
	if not valo_paalla_pysyvasti:
		aloita_animaatio(1, 0, 2)
		collision_shape.position = Vector2(-9999, -9999)
		if area.is_in_group("valonlahde"):
			area.remove_from_group("valonlahde")
	else:
		aseta_valon_skaala(1)


## Asettaa valolle uuden skaalan ja laittaa sen samalla päälle.
## Asetettu skaala on vähintään nykyisen valon kokoinen.
func aseta_valon_skaala(skaala):
	if not valo_paalla_pysyvasti:
		skaala = max(skaala, point_light.get_texture_scale())

	collision_shape.position = Vector2(0, 0)

	aloita_animaatio(skaala, 1, 3)

	if not area.is_in_group("valonlahde"):
		area.add_to_group("valonlahde")
	print_debug(area.is_in_group("valonlahde"))


## Valon lisääminen pallon osuttua
func _on_body_entered(body):
	if body.is_in_group("valopallo"):
		valo_paalla_pysyvasti = true
		if not area.is_in_group("valonlahde"):
			aseta_valon_skaala(1)


## Kun osutaan huiluun
func _on_area_entered(_area:Area2D):
	if _area is Huilu && _area.aanen_taajuus == 1:
		aseta_valon_skaala(2)
		huilu_ajastin.start()
