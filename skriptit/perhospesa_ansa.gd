@tool
## Yksinkertainen ansa
## aktivoi vahinkoa tekevän alueen tietyn aikavälein
## Juuso 16.3.2024
extends Node2D
class_name Ansa

@export_group("Ansan vahinko")
@export var vahinko_per_tick: float = 0.5
@export var vahinko_timeout: float = 0.75
@export_group("Ansan ajoitukset")
@export var aika_aktivoituna: int = 5 ## Kauanko pysyy aktivoituna
@export var aika_transitio: int = 3 ## Kauanko kestää mennä aktiiviseksi ja epäaktiiviseksi
@export var cooldown: int = 4 ## Kauanko pysyy epäaktiivisena
@export var aloitus_delay: float = 0.0 ## Kauanko odottaa ennen syklin aloittamista
@export_group("Ansan koko ja partikkelit")
## Helpompi tapa muuttaa collision polygonin skaalaa
## muuttaa samalla partikkelien elinaikaa kuvastamaan uutta vahingon teko aluetta
@export var c_p2d_scale: float = 1.0: ## Koko polygonin skaala
	set(value):
		c_p2d_scale = value
		if not Engine.is_editor_hint():
			return
		# Jos vaihtaa skene tabissa maailmaan, niin pitää odottaa että lapsinodet ovat ready
		if not is_inside_tree():
			await self.ready
		if is_zero_approx(c_p2d_scale_x - 1.0):
			collision_p2d.scale = Vector2(value, value)
		else:
			collision_p2d.scale = Vector2(c_p2d_scale_x, value)
		nykyinen_lifetime = paivita_lifetime(value)
		#prints("Uusi lifetime", cpu_p2d.lifetime)

@export var c_p2d_scale_x: float = 1.0: ## X skaala
	set(value):
		c_p2d_scale_x = value
		if not Engine.is_editor_hint():
			return
		if not is_inside_tree():
			await self.ready
		collision_p2d.scale.x = value

@export var partikkeli_spread: float = 27.5: ## Partikkelien hajautumisen aste
	set(value):
		partikkeli_spread = value
		if not Engine.is_editor_hint():
			return
		if not is_inside_tree():
			await self.ready
		cpu_p2d.spread = value

## Tätä ei ole syytä muuttaa manuaalisti, tämä lasketaan uudelleen kun peli alkaa
@export var nykyinen_lifetime: float = oletus_lifetime:
	set(value):
		nykyinen_lifetime = value

var oletus_lifetime: float = 3.3

@onready var collision_p2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var cpu_p2d: CPUParticles2D = $CPUParticles2D

var tween: Tween
var timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Export muuttujiin liittyen
	paivita_lifetime(c_p2d_scale)
	cpu_p2d.spread = partikkeli_spread
	
	collision_p2d.scale = Vector2.ZERO
	cpu_p2d.emitting = false
	aloita_sykli()


## Päivittää partikkelin lifetimen, kun peli alkaa
## Menevät aika hyvin yksi yhteen skaalan kanssa
func paivita_lifetime(value: float) -> float:
	cpu_p2d.lifetime = oletus_lifetime * value
	return cpu_p2d.lifetime


## Aloittaa syklin, jossa ansa aktivoituu ja deaktivoituu aikavälein
func aloita_sykli():
	# TODO: ei ehkä tarvitse
	await get_tree().create_timer(aloitus_delay, false).timeout
	# Respawnatessa
	if tween:
		tween.kill()
		collision_p2d.scale = Vector2.ZERO
		cpu_p2d.emitting = false
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	# Jos ei olla skaalattu x-suunnassa, tween normaalisti koko skaalalla
	# Kesto voi muuttua aika_transition muokkausten takia
	if is_zero_approx(c_p2d_scale_x - 1.0):
		tween.tween_property(collision_p2d, "scale", Vector2(c_p2d_scale, c_p2d_scale), aika_transitio)
	else:
		tween.tween_property(collision_p2d, "scale", Vector2(c_p2d_scale_x, c_p2d_scale), aika_transitio)
	cpu_p2d.emitting = true
	tween.tween_interval(aika_aktivoituna) # Pysyy aktivoituna
	tween.tween_callback(func():
		cpu_p2d.emitting = false)
	tween.tween_property(collision_p2d, "scale", Vector2.ZERO, aika_transitio)
	tween.tween_callback(deaktivoi)
	tween.tween_interval(cooldown) # Pysyy epäaktiivisena
	tween.tween_callback(aktivoi)


## Aktivoi collisionin, aloittaa partikkelien tuottamisen jne...
func aktivoi():
	cpu_p2d.emitting = true
	# Ei aktivoida heti, pieni viive
	await get_tree().create_timer(1, false).timeout
	collision_p2d.set_deferred("disabled", false)
	# Visuaalisuus, äänet


## Deaktivoi collisionin
func deaktivoi():
	cpu_p2d.emitting = false
	collision_p2d.set_deferred("disabled", true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		#print_debug("Ansassa ", self.name)
		timer = Timer.new()
		timer.wait_time = vahinko_timeout
		timer.timeout.connect(body.myrkky_damage)
		body.add_child(timer)
		# Nimi lisäämisen jälkeen, ettei muuta automaattisesti muotoon @Timer...
		timer.name = "TimerAnsa"
		timer.start()
		print_debug(self.name, " LUOTU AJASTIN ", timer.name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		#print_debug("Poistuttu ansasta ", self.name)
		if timer:
			if timer.is_stopped():
				timer.queue_free()
			else:
				print_debug(self.name, " TUHOTTU AJASTIN ", timer.name)
				await timer.timeout # TODO: tuntuu hieman paremmalle näin
				timer.queue_free()
		else:
			printerr("EI LÖYTYNYT AJASTINTA", self.name)
