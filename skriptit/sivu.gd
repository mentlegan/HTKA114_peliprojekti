extends Area2D
## Journalin sivun pickup-itemi


@onready var animated_sprite = $AnimatedSprite2D
@onready var point_light = $PointLight2D

## Sivun tekstipätkä
@export var teksti: String
## Sivun otsikko
@export var otsikko: String
## Sivunumero
@export_range(1, 20) var sivunumero: int

var tween: Tween


func _ready():
	animated_sprite.play()


func _on_body_entered(body):
	if body is Pelaaja:
		# Ei aloiteta pickup animaatiota uudestaan
		if tween:
			return
		
		# Lisätään journaliin sivu
		Globaali.lisaa_sivu(teksti, otsikko, sivunumero)

		# Aloitetaan pickup animaatio
		point_light.energy = 2
		animated_sprite.scale = Vector2(1.5, 1.5)
		point_light.blend_mode = 0

		tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(self, "modulate:a", 0, 2)
		tween.tween_property(animated_sprite, "position:y", -20, 2)
		tween.tween_property(animated_sprite, "scale", Vector2.ONE, 2)
		tween.tween_property(point_light, "texture_scale", 3, 2)
		tween.tween_property(point_light, "energy", 0, 2)
		tween.finished.connect(aseta_pois_paalta)


## Asettaa sivun pois päältä
func aseta_pois_paalta():
	self.set_process(false)
	self.visible = false