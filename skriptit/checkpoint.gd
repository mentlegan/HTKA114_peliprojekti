## Juuso 5.12.2024
## Checkpointtien käsittely
## Nyt checkpointin voi asettaa uudelleen aktiiviseksi
extends Area2D
class_name Checkpoint

@export_group("Valon värit")
@export var vari_aktivoitu: Color
@export var vari_nykyinen_aktiivinen: Color # Saa muuttaa

## Totuusarvo sille onko päällä
var aktivoitu = false

@onready var valo: PointLight2D = $Area2D/PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	valo.color = vari_aktivoitu


func _on_body_entered(body):
	if body is Pelaaja:
		var nykyinen_cp: Checkpoint = Globaali.maailma.nykyinen_cp
		if nykyinen_cp == self:
			print_debug("Sama checkpoint ", self.name)
			return
		
		Globaali.maailma.pelaaja_aloitus = self.global_position
		Globaali.maailma.nykyinen_cp = self
		if not aktivoitu:
			aktivoi()
		else:
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(valo, "color", vari_nykyinen_aktiivinen, 1)
			print_debug("Asetetaan uusi aktiiviseksi ", self.name)
		
		# Muulloin kuin aivan ekalla checkpointilla
		# Resetataan edellinen
		if not nykyinen_cp == null:
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(nykyinen_cp.valo, "color", vari_aktivoitu, 1)
			print_debug("Resetataan edellinen ", self.name)


## Aktivoi checkpointin
func aktivoi():
	aktivoitu = true
	valo.visible = true
	$AnimatedSprite2D.play("activate")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(valo, "texture_scale", 3, 2)
	tween.tween_property($Area2D/CollisionShape2D, "scale", Vector2(3, 3), 2)
	tween.tween_property(valo, "energy", 1.2, 2)
	await tween.finished
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(valo, "color", vari_nykyinen_aktiivinen, 1)
