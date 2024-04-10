## Juuso 22.3.2024
## Paavo 10.4.2024
## Kukkien ominaisuudet luonnossa

extends Area2D

## Kukan valo ja valonlähteen oma CollisionShape2D valon tarkistusta varten.
@onready var valo_area2d = $Area2D
@onready var valo = $Area2D/PointLight2D
@onready var valo_collision = $Area2D/CollisionShape2D

## Ajastimet huilua varten
@onready var taajuus_1_ajastin = $Taajuus1Ajastin
@onready var taajuus_2_ajastin = $Taajuus2Ajastin

## Tekstuurit valolle
var valo_tekstuuri_pieni = preload("res://grafiikka/Valo64.png")
var valo_tekstuuri_suuri = preload("res://grafiikka/Valo256.png")

## Muuttuja sille, onko valo asetettu päälle valopallolla
var valo_paalla_pysyvasti = false


## Asetetaan ajastimien timeout-funktiot ja valon tekstuuri
func _ready():
	# Yhdistetään ajastimet huilun ominaisuuksilta palautumiseen
	taajuus_1_ajastin.timeout.connect(aseta_valo_pois_paalta)
	taajuus_2_ajastin.timeout.connect(aseta_valon_tekstuuri)

	# Asetetaan varulta valon tekstuuri pelin alussa
	aseta_valon_tekstuuri()


## Asettaa valolle uuden tekstuurin
func aseta_valon_tekstuuri(tekstuuri = valo_tekstuuri_pieni):
	valo.set_texture(tekstuuri)


## Asettaa kukan valon pois päältä
func aseta_valo_pois_paalta():
	if valo_paalla_pysyvasti:
		return
	
	valo.set_visible(false)
	if valo_area2d.is_in_group("valonlahde"):
		valo_area2d.remove_from_group("valonlahde")


## Asettaa kukan valon päälle, joko pysyvästi tai ajastimella
func aseta_valo_paalle(pysyva, huilun_taajuus = 0):
	valo.set_visible(true)

	if not valo_area2d.is_in_group("valonlahde"):
		valo_area2d.add_to_group("valonlahde")

	if not pysyva:
		if (taajuus_1_ajastin.is_stopped() && huilun_taajuus == 1):
			taajuus_1_ajastin.start()
		elif (taajuus_2_ajastin.is_stopped() && huilun_taajuus == 2):
			taajuus_2_ajastin.start()
			aseta_valon_tekstuuri(valo_tekstuuri_suuri)
	else:
		if not taajuus_1_ajastin.is_stopped():
			taajuus_1_ajastin.stop()
		if not taajuus_2_ajastin.is_stopped():
			taajuus_2_ajastin.stop()
	
	if pysyva:
		valo_paalla_pysyvasti = true


## Valon lisääminen pallon osuttua
func _on_body_entered(body):
	if body.is_in_group("valopallo") and not valo_paalla_pysyvasti:
		aseta_valo_paalle(true)
		
		# queue_free() # Poistetaan kukka luonnosta, kun se on kerätty
		# Ei poisteta ainakaan ensimmäisiä kukkia, jotta valopalloja voi ottaa loputtomasti


## Kun osutaan huiluun
func _on_area_entered(area:Area2D):
	if area is Huilu:
		aseta_valo_paalle(false, area.aanen_taajuus)
