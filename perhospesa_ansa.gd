## Yksinkertainen ansa
## aktivoi vahinkoa tekevän alueen tietyn aikavälein
## Juuso 5.12.2024
extends Node2D

@export_group("Ansan statsit")
@export var aika_aktivoituna: int = 5
@export var aika_transitio: int = 3
@export var cooldown: int = 4
@export_group("Ansan vahinko")
@export var vahinko_per_tick: float = 0.5
@export var vahinko_timeout: float = 0.75

@onready var collision_p2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D

var tween: Tween
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_p2d.scale = Vector2.ZERO # Jotta helpompi muokata editorissa
	aloita_sykli()


## Aloittaa syklin, jossa ansa aktivoituu ja deaktivoituu aikavälein
func aloita_sykli():
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	tween.tween_property(collision_p2d, "scale", Vector2.ONE, aika_transitio)
	tween.tween_interval(aika_aktivoituna) # Pysyy aktivoituna
	tween.tween_property(collision_p2d, "scale", Vector2.ZERO, aika_transitio)
	tween.tween_callback(deaktivoi)
	tween.tween_interval(cooldown) # Pysyy epäaktiivisena
	tween.tween_callback(aktivoi)


## Aktivoi collisionin, aloittaa partikkelien tuottamisen jne...
func aktivoi():
	# Ei aktivoida heti, pieni viive
	await get_tree().create_timer(1).timeout
	collision_p2d.set_deferred("disabled", false)
	# Visuaalisuus, äänet


## Deaktivoi collisionin
func deaktivoi():
	collision_p2d.set_deferred("disabled", true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		#print_debug("Ansassa ", self.name)
		timer = Timer.new()
		timer.name = "TimerAnsa"
		timer.wait_time = vahinko_timeout
		timer.timeout.connect(body.myrkky_damage)
		body.add_child(timer)
		timer.start()
		print_debug(self.name, " LUOTU AJASTIN ", timer.name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		#print_debug("Poistuttu ansasta ", self.name)
		if timer:
			timer.queue_free()
		else:
			printerr("EI LÖYTYNYT AJASTINTA", self)
