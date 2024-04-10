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
		Globaali.pelaaja_aloitus = self.global_position
		aktivoitu = true
		var lapset = self.get_children()
		for lapsi in lapset:
			if lapsi is PointLight2D:
				lapsi.set_visible(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
