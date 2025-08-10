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

@onready var audio_valokukan_resonanssi = $AudioValokukanResonanssi

@onready var partikkelit = $CPUParticles2D

@onready var animaatio = $AnimatedSprite2D

## Muuttuja sille, onko valo asetettu päälle valopallolla
var valo_paalla_pysyvasti = false
## Cooldownia varten
var voiko_kerata = true

## Tween kukan animaatiota varten
var tween: Tween


## Asetetaan ajastimien timeout-funktiot ja valon tekstuuri
func _ready():
	# Yhdistetään ajastimet huilun ominaisuuksilta palautumiseen
	huilu_ajastin.timeout.connect(sulje_valo)
	
	partikkelit.one_shot = true
	partikkelit.emitting = false
	
	kerays_cooldown.timeout.connect(vaihda_kerays)
	animaatio.play("default")
	animaatio.animation_looped.connect(vaihda_animaatio)


## Vaihtaa / pysäyttää animaation, jos ei olla default-animaatiossa
func vaihda_animaatio():
	match animaatio.get_animation():
		"default":
			return
		"disable":
			animaatio.pause()
			animaatio.set_frame(4)
		"enable":
			animaatio.play("default")


func aloita_kerays():
	kerays_cooldown.start()
	voiko_kerata = false
	sulje_valo()
	animaatio.play("disable")


func vaihda_kerays():
	voiko_kerata = true
	aseta_valon_skaala(1)
	animaatio.play("enable")


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
		tween_valo_pysyvasti()
	#print_debug(area.is_in_group("valonlahde"))


func tween_valo_pysyvasti() -> void:
	var tween_vain_kerran: Tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	print_debug(self.name, " tween vain kerran")
	tween_vain_kerran.tween_property(animaatio, "scale", Vector2(1.2, 1.2), 0.4)
	tween_vain_kerran.parallel().tween_property(animaatio, "modulate", Color.YELLOW_GREEN, 0.4)
	tween_vain_kerran.parallel().tween_property(animaatio, "modulate:a", 0.6, 0.4)
	tween_vain_kerran.tween_property(animaatio, "scale", Vector2.ONE, 0.3)
	tween_vain_kerran.parallel().tween_property(animaatio, "modulate", Color.WHITE, 0.5)
	tween_vain_kerran.parallel().tween_property(animaatio, "modulate:a", 1.0, 0.4)
	# TODO: Ääni ja mahd. valo pysyvästi esim. tehokkaammaksi?


## Valon lisääminen pallon osuttua
func _on_body_entered(body):
	if body.is_in_group("valopallo"):
		valo_paalla_pysyvasti = true
		aseta_valon_skaala(1)


## Kun osutaan huiluun
func _on_area_entered(_area: Area2D):
	if _area is Huilu && _area.aanen_taajuus == 1:
		if not _area.osuu_terrainiin(self):
			var resonanssiaanen_ajastin = Timer.new()
			resonanssiaanen_ajastin.set_one_shot(true)
			resonanssiaanen_ajastin.timeout.connect(audio_valokukan_resonanssi.play)
			self.add_child(resonanssiaanen_ajastin)
			resonanssiaanen_ajastin.start(0.8)
			aseta_valon_skaala(2)
			huilu_ajastin.start()
