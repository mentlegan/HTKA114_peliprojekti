## Juuso 10.4.2024
## Checkpointtien käsittely
## Tällä hetkellä ei voi aktivoida jo aiemmin aktivoitua checkpointtia uudelleen,
## jos on esimerkiksi aktivoinut jonkin toisen tässä välissä
extends Area2D

## Totuusarvo sille onko päällä
var aktivoitu = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body):
	if body is Pelaaja and not aktivoitu:
		# Vaihdetaan pelaajan spawn-point
		Globaali.maailma.pelaaja_aloitus = self.global_position
		aktivoitu = true
		$AnimatedSprite2D.play("activate")
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
		tween.tween_property($Area2D/PointLight2D, "texture_scale", 3, 2)
		tween.tween_property($Area2D/CollisionShape2D, "scale", Vector2(3, 3), 2)
		tween.tween_property($Area2D/PointLight2D, "energy", 1.2, 2)
		$Area2D/PointLight2D.visible = true
