## Yksinkertainen ansa
## aktivoi vahinkoa tekevän alueen tietyn aikavälein
## Juuso 5.12.2024
extends Node2D

@export_group("Ansan statsit")
@export var aika_aktivoituna: int = 5
@export var aika_aktivoituu_ja_sammuu: int = 3
@export var cooldown: int = 4
@export_group("Ansan vahinko")
@export var vahinko_per_tick: float = 0.5
@export var vahinko_timeout: float = 0.75

@onready var collision_p2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_p2d.scale = Vector2.ZERO
	aloita_sykli()


## Aloittaa syklin, jossa ansa aktivoituu ja deaktivoituu aikavälein
func aloita_sykli():
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	tween.tween_property(collision_p2d, "scale", Vector2.ONE, aika_aktivoituu_ja_sammuu)
	tween.tween_interval(aika_aktivoituna)
	tween.tween_property(collision_p2d, "scale", Vector2.ZERO, aika_aktivoituu_ja_sammuu)
	tween.tween_callback(deaktivoi)
	tween.tween_interval(cooldown)
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
		print_debug("Ansassa ", self.name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		print_debug("Poistuttu ansasta ", self.name)
