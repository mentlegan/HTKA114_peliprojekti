## Harri 14.3.2024
## TODO: Ääniefektin korkeuden muuttaminen

extends CharacterBody2D

const SPEED = 50.0
signal pelaaja_kuollut

## Ajastin vihollisen äänille paikalla ollessaan
const IDLE_AUDIO_AJASTIN_MAX = 15.0 ## Ajastin asetetaan satunnaisesti 50-100%:iin tästä arvosta sen alkaessa
@onready var idle_audio_ajastin = Timer.new()

## Ääniefektien nodet
@onready var audio_paikoillaan = $AudioPaikoillaan
@onready var audio_jahtaus = $AudioJahtaus
@onready var audio_pakeneminen = $AudioPakeneminen

## Valontarkistus-node
@onready var valon_tarkistus = $ValonTarkistus

## Keho-node
@onready var keho = $Keho

var jahdissa = false ## Vakiona vihollinen ei ole jahtaamassa pelaajaa
var pakenee = false
var pelaaja = null
var valossa = false
var menossa_kuoppaan = null

## Taulukko kuopille, joihin vihollinen voi kaivautua
var kuopat = Array()
## Kuoppa, jonne vihollinen on viimeksi kaivautunut
var kuoppa_indeksi = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	# Ajastimen toimintaa varten kutsutaan randomize()
	randomize()
	
	# Kutsutaan ajastimen loppuessa funktiota _idle_audio_ajastimen_loppuessa
	idle_audio_ajastin.timeout.connect(_idle_audio_ajastimen_loppuessa)
	
	# Lisätään ajastin lapseksi
	self.add_child(idle_audio_ajastin)
	
	# Aloitetaan ajastin idle-ääniefektille
	aloita_idle_audio_ajastin()
	
	# Etsitään sisarus-nodeista kuopat
	for sisarus in get_parent().get_children():
		if sisarus is Kuoppa:
			kuopat.append(sisarus)
	
	# Yhdistetään valon signaalit vihollisen omiin funktioihin
	valon_tarkistus.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus.connect("siirrytty_varjoon", siirrytty_varjoon)


## Etsii vihollisen kuopista seuraavan, jonne paeta
func seuraava_kuoppa():
	menossa_kuoppaan = kuopat[kuoppa_indeksi]
	kuoppa_indeksi = (kuoppa_indeksi + 1) % len(kuopat)


## Kun siirrytään valoon
## Tarkistetaan samalla, onko vihollinen kuopan päällä, jonne lähtisi menemään
func siirrytty_valoon():
	# Jatketaan pakenemista, jos vihollinen ei ole kerennyt vielä kuoppaan
	if pakenee:
		return
	
	pakenee = true
	jahdissa = false
	valossa = true
	seuraava_kuoppa()
	
	for node in keho.get_overlapping_areas():
		if node == menossa_kuoppaan:
			lopeta_pakeneminen()


## Kun siirrytään varjoon
func siirrytty_varjoon():
	# Jatketaan pakenemista, jos vihollinen ei ole kerennyt vielä kuoppaan
	if pakenee:
		return
	
	valossa = false


## Aloittaa ajastimen idle-ääniefektille
func aloita_idle_audio_ajastin():
	idle_audio_ajastin.start((1 - randf() * 0.5) * IDLE_AUDIO_AJASTIN_MAX)


## Lopettaa pakenemisen ja teleportaa seuraavaan kuoppaan
func lopeta_pakeneminen():
	pakenee = false
	valossa = false
	seuraava_kuoppa()
	print(menossa_kuoppaan)
	self.global_position = menossa_kuoppaan.global_position


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta # Painovoimaa vihollisellekin
	if jahdissa: # Tässä "jahtimoodi" eli kun vihollinen tietää, että missä pelaaja on
		position += (pelaaja.position - position)/SPEED
	elif pakenee:
		position += (menossa_kuoppaan.global_position - position)/SPEED
	move_and_slide()


## Idle audio ajastimen loppuessa soitetaan idle ääniefekti
func _idle_audio_ajastimen_loppuessa():
	if audio_paikoillaan.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	
	# Lopetetaan jahtausääniefektit, jos niitä soitetaan
	if audio_jahtaus.is_playing():
		audio_jahtaus.stop()
	
	audio_paikoillaan.play()


## Kun pelaaja osuu viholliseen, käynnistetään scene uudestaan
func _on_keho_body_entered(body):
	if body.is_in_group("Pelaaja"):
		pelaaja = body
		pelaaja_kuollut.emit() # Voidaan kutsua respawnia signaalilla. Tätä samaa voi kutsua muissa game overin instansseissa


## Jos pelaaja astuu vihollisen tietoisuusalueelle
func _on_tarkkaavaisuus_body_entered(body):
	# Jatketaan pakenemista, jos vihollinen ei ole kerennyt vielä kuoppaan
	if pakenee:
		return
	
	pelaaja = body
	jahdissa = true
	
	# Pysäytetään mahdollinen idle-ääniefekti ja soitetaan vihollisen jahtaus-ääniefekti
	if audio_paikoillaan.is_playing():
		audio_paikoillaan.stop()
		idle_audio_ajastin.stop()
	
	# Jos jahtaus-ääniefekti on jo pyörimässä, ei tehdä mitään
	if not audio_jahtaus.is_playing():
		audio_jahtaus.play()


## Jos pelaaja poistuu vihollisen tietoisuusalueelta
func _on_tarkkaavaisuus_body_exited(_body):
	# Jatketaan pakenemista, jos vihollinen ei ole kerennyt vielä kuoppaan
	if pakenee:
		return
	
	pelaaja = null
	jahdissa = false
	
	# Aloitetaan ajastin idle-ääniefektille, jos se on pois päältä
	if idle_audio_ajastin.is_stopped():
		aloita_idle_audio_ajastin()


## Jos viholliseen osuu paetessa kuoppaan, lopetetaan pakeneminen ja teleportataan seuraavaan
func _on_keho_area_entered(area):
	if area is Kuoppa and pakenee:
		lopeta_pakeneminen()
