## Harri 7.3.2024
## TODO: Ääniefektin korkeuden muuttaminen

extends CharacterBody2D

const SPEED = 50.0

## Ajastin vihollisen äänille paikalla ollessaan
const IDLE_AUDIO_AJASTIN_MAX = 15.0 ## Ajastin asetetaan satunnaisesti 50-100%:iin tästä arvosta sen alkaessa
@onready var idle_audio_ajastin = Timer.new()

## Ääniefektien nodet
@onready var audio_paikoillaan = $AudioPaikoillaan
@onready var audio_jahtaus = $AudioJahtaus

var jahdissa = false ## Vakiona vihollinen ei ole jahtaamassa pelaajaa
var pelaaja = null

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
	idle_audio_ajastin.start((1 - randf() * 0.5) * IDLE_AUDIO_AJASTIN_MAX)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta ## Painovoimaa vihollisellekin
	if jahdissa: ## Tässä "jahtimoodi" eli kun vihollinen tietää, että missä pelaaja on
		position += (pelaaja.position - position)/SPEED
	move_and_slide()


func _idle_audio_ajastimen_loppuessa(): ## Idle audio ajastimen loppuessa soitetaan idle ääniefekti
	if audio_paikoillaan.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	
	# Lopetetaan jahtausääniefektit, jos niitä soitetaan
	if audio_jahtaus.is_playing():
		audio_jahtaus.stop()
	
	audio_paikoillaan.play()


func _on_keho_body_entered(body): ## Kun pelaaja osuu viholliseen, käynnistetään scene uudestaan
	if body.is_in_group("Pelaaja"):
		pelaaja = body
		Globaali.respawn() ## Voidaan kutsua respawnia näinkin. Tätä samaa voi kutsua muissa game overin instansseissa


func _on_tarkkaavaisuus_body_entered(body): ## Jos pelaaja astuu vihollisen tietoisuusalueelle
	pelaaja = body
	jahdissa = true
	
	# Pysäytetään mahdollinen idle-ääniefekti ja soitetaan vihollisen jahtaus-ääniefekti
	if audio_paikoillaan.is_playing():
		audio_paikoillaan.stop()
		idle_audio_ajastin.stop()
	
	# Jos jahtaus-ääniefekti on jo pyörimässä, ei tehdä mitään
	if not audio_jahtaus.is_playing():
		audio_jahtaus.play()


func _on_tarkkaavaisuus_body_exited(body): ## Jos pelaaja poistuu vihollisen tietoisuusalueelta
	pelaaja = null
	jahdissa = false
	
	# Aloitetaan ajastin idle-ääniefektille, jos se on pois päältä
	if idle_audio_ajastin.is_stopped():
		idle_audio_ajastin.start((1 - randf() * 0.5) * IDLE_AUDIO_AJASTIN_MAX)
