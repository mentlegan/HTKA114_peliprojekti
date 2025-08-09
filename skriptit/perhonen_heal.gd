@tool
extends Perhonen
class_name PerhonenHeal
## Healaava perhonen
## Juuso 9.8.2025

@export var timer_heal_node: PackedScene
@export var partikkelit_vari: Color: set = set_partikkelit_vari

@onready var plight_2d: PointLight2D = $PointLight2D
@onready var line_2d: Line2DPerhonen = $Line2D

@onready var partikkelit: GPUParticles2D = $GPUParticles2D

var timer_heal: TimerHeal

var pelaaja: Pelaaja

var aloitus_texture_scale: float
var aloitus_energia: float
var line2d_aloitus_alpha: float

## Näistä en ole varma
## ei ole hyvä ellei tee useampaa aaltoa ja samalla partikkeleja varmaan
#var aalto_paivitys_aika: float = 0.0
#var aalto_paivitys_raja: float = 0.25 ## Kuinka usein aalto paivitetaan

var tween: Tween
var tween_aalto: Tween

func _ready() -> void:
	super._ready()
	
	# Äänet mutelle editorissa
	if Engine.is_editor_hint():
		aanen_ajastin.stop()
	
	aloitus_texture_scale = plight_2d.texture_scale
	aloitus_energia = plight_2d.energy
	
	set_partikkelit_vari(partikkelit_vari)
	
	if not Engine.is_editor_hint():
		line2d_aloitus_alpha = line_2d.modulate.a
		line_2d.modulate.a = 0.0
		partikkelit.position = Vector2.ZERO
		partikkelit.emitting = false
		partikkelit.one_shot = true


func set_partikkelit_vari(vari: Color) -> void:
	partikkelit_vari = vari
	if partikkelit:
		partikkelit.modulate = partikkelit_vari


## Luo ajastimen pelaajalle, joka kutsuu elama_regen funktiota
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		pelaaja = body
		luo_heal_timer()
		aloita_heal()


func luo_heal_timer() -> void:
	timer_heal = timer_heal_node.instantiate()
	timer_heal.aseta_kohde(pelaaja)
	pelaaja.add_child(timer_heal)
	timer_heal.aseta_nimi()


func aloita_heal() -> void:
	if tween:
		tween.kill()
	
	# Kauanko ennen healin latauksen loppua line2d aalto tween aloitetaan
	var tween_aalto_aloitus: float = 0.15
	
	# Muutokset valon texture scaleen
	var valon_scale_lataus: float = aloitus_texture_scale - 0.4
	var valon_scale_burst: float = aloitus_texture_scale + 0.45
	
	# Valon energian muutokset
	var valon_energia_kerroin: float = 1.15 # Burstin aikana saavuttaa tällä kerrotun energian
	# Lataamisen aikana saavutettu alin energiataso
	var valon_energia_burst: float = aloitus_energia * valon_energia_kerroin
	var valon_energia_lataaminen: float = aloitus_energia / valon_energia_kerroin - 0.1
	var valon_voimistumis_aika: float = 0.25
	var valon_heikkenemis_aika: float = 0.35
	
	# Edellä oleva tweenaus koodi on mahdollisesti hieman vaikeasti ymmärrettävää
	# olisi ehkä parempi tehdä animationplayerillä
	# Sillä ei vaan saa otettua huomioon timer_heal.data muuttujia ainakaan helposti
	
	# Ideana tässä efektissä on, että latautuminen olisi aluksi nopeampaa, lopuksi hidasta
	# Burst aluksi hitaampi, lopuksi nopeampi
	# Palautuminen tasaista
	tween = create_tween().set_loops(0)
	# Valon pieneneminen (lataus)
	tween.tween_property(plight_2d, "texture_scale", 
						valon_scale_lataus, 
						timer_heal.data.lataus_aika).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Energian vähennys lataamisen aikana
	tween.parallel().tween_property(plight_2d, "energy", 
						valon_energia_lataaminen, 
						timer_heal.data.lataus_aika).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# TODO: mm. partikkelit, ääni
	# Lähetä visuaalinen efekti silloin, kun latautuminen on lähellä loppua
	# TAI: ENNEN (juuri) kuin heal tapahtuu
	# eli muuta delay sopimaan hyvin
	tween.parallel().tween_callback(heal_efekti).set_delay(
		timer_heal.data.lataus_aika - tween_aalto_aloitus)
	
	# Valon laajeneminen maksimaaliseksi (burst)
	tween.tween_property(plight_2d, "texture_scale", 
						valon_scale_burst, 
						timer_heal.data.burst_aika).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	# Valon energian lisääminen laajenemisen aikana, maksimaalinen juuri kuin burst loppuu
	tween.parallel().tween_property(plight_2d, "energy", 
						valon_energia_burst,
						valon_voimistumis_aika).set_ease(Tween.EASE_IN).set_trans(
							Tween.TRANS_SINE).set_delay(timer_heal.data.burst_aika - valon_voimistumis_aika)
	# Valon palautuminen takaisin normaaliksi (palautuminen)
	tween.tween_property(plight_2d, "texture_scale", 
						aloitus_texture_scale, 
						timer_heal.data.palautumis_aika).set_trans(Tween.TRANS_LINEAR)
	# Valon energia takaisin normaaliksi samalla texture scalen kanssa
	tween.parallel().tween_property(plight_2d, "energy", 
						aloitus_energia, 
						valon_heikkenemis_aika).set_trans(Tween.TRANS_SINE)


# Heal efekti, ajatuksena on tehdä aaltomainen efekti pelaajaa kohti
# Ikään kuin pelaaja ja perhonen "yhdistyvät" hetkellisesti, jonka aikana pelaajaa healataan
# TODO: miten implementoida parhaiten, mietin partikkelien tai suoraan
# aaltomaisen materiaalin kautta joko shaderilla tai Line2D avulla
# Tällä hetkellä testausta Line2D avulla muodostaen aallon pisteiden kautta pelaajaa kohti
func heal_efekti() -> void:
	if tween_aalto:
		tween_aalto.kill()
	
	print("Heal aalto-efekti")
	var aalto_nakyviin_aika: float = 0.45
	var aalto_himmenemis_aika: float = 0.25
	var partikkelit_nakyviin_aika: float = 0.15
	
	# Partikkelit
	# TODO: tekstuuri partikkeleille, joko nykyinen tai valopallon
	# Käytetään hyväksi line_2d, jolla 10 pistettä atm
	#partikkelit.position = line_2d.palauta_keskipiste()
	#partikkelit.rotation = self.global_position.direction_to(pelaaja.global_position).angle()
	#partikkelit.emitting = true
	
	tween_aalto = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_aalto.tween_property(line_2d, "modulate:a", line2d_aloitus_alpha, aalto_nakyviin_aika)
	tween_aalto.tween_property(line_2d, "modulate:a", 0.0, aalto_himmenemis_aika).set_trans(Tween.TRANS_QUINT)
	
	# Odotetaan hetki partikkelien kanssa samalla kun aaltoa tweenataan
	var tween_parallel: Tween = create_tween()
	tween_parallel.tween_interval(partikkelit_nakyviin_aika)
	tween_parallel.tween_callback(func():
		partikkelit.emitting = true)
	
	# TODO: pelaajan efekti, olisiko vihreäksi väläyttäminen
	# siis käytännössä sama efekti kuin damagea ottaessa


## Poistetaan ajastin ja resetoidaan valo, kun pelaaja poistuu alueelta
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		pelaaja = null
		if tween:
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
		tween.tween_property(plight_2d, "texture_scale", aloitus_texture_scale, timer_heal.data.palautumis_aika)
		tween.tween_property(plight_2d, "energy", aloitus_energia, timer_heal.data.palautumis_aika)
		if timer_heal:
			timer_heal.tuhoa()
		else:
			printerr("PELAAJALTA EI LÖYTYNYT AJASTINTA", self.name)


## Päivitetään aaltoa pelaajan liikkuessa, kun aalto tween on aktiivinen
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	super._physics_process(delta)
	if pelaaja:
		if tween_aalto and tween_aalto.is_running():
			#aalto_paivitys_aika += delta
			#if aalto_paivitys_aika > aalto_paivitys_raja:
				#aalto_paivitys_aika = 0.0
				# TODO: Tarvitseeko päivittää joka physics framella
				# voisi olla efektin kannalta parempi, jos ei seuraa niin vahvasti pelaajaa
				# esim. joka kolmas frame
				# Ei näyttänyt hyvälle, jos viivytti päivittämistä,
				# tällöin pitäisi tehdä useampi aaltoefekti
			partikkelit.position = line_2d.palauta_keskipiste()
			partikkelit.rotation = self.global_position.direction_to(pelaaja.global_position).angle()
			line_2d.muodosta_aalto(self.global_position, pelaaja.global_position)
