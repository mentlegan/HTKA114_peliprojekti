## Juuso 22.3.2024
## Paavo 10.4.2024
## Kukkien ominaisuudet luonnossa

extends Area2D

## Kukan nodet
@onready var huilu_ajastin = $HuiluAjastin

@onready var area = $Area2D
@onready var point_light = $Area2D/PointLight2D
@onready var collision_shape = $Area2D/CollisionShape2D

## Muuttuja sille, onko valo asetettu päälle valopallolla
var valo_paalla_pysyvasti = false


## Asetetaan ajastimien timeout-funktiot ja valon tekstuuri
func _ready():
	sulje_valo()
	# Yhdistetään ajastimet huilun ominaisuuksilta palautumiseen
	huilu_ajastin.timeout.connect(sulje_valo)


## Sulkee kukan valon
func sulje_valo():
	if not valo_paalla_pysyvasti:
		point_light.set_visible(false)
		#collision_shape.set_disabled(true)
		if area.is_in_group("valonlahde"):
			area.remove_from_group("valonlahde")
	else:
		aseta_valon_skaala(1)


## Asettaa valolle uuden skaalan ja laittaa sen samalla päälle.
## Asetettu skaala on vähintään nykyisen valon kokoinen.
func aseta_valon_skaala(skaala):
	if not valo_paalla_pysyvasti:
		skaala = max(skaala, point_light.get_texture_scale())

	point_light.set_texture_scale(skaala)
	point_light.set_visible(true)
	collision_shape.set_scale(Vector2(skaala, skaala))
	#collision_shape.set_disabled(false)

	if not area.is_in_group("valonlahde"):
		area.add_to_group("valonlahde")
	print_debug(area.is_in_group("valonlahde"))


## Valon lisääminen pallon osuttua
func _on_body_entered(body):
	if body.is_in_group("valopallo"):
		valo_paalla_pysyvasti = true
		aseta_valon_skaala(1)


## Kun osutaan huiluun
func _on_area_entered(_area:Area2D):
	if _area is Huilu && _area.aanen_taajuus == 1:
		aseta_valon_skaala(2)
		huilu_ajastin.start()