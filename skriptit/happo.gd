extends CharacterBody2D
class_name Happo
## TODO: Pelaajalle kilpi hapon torjumiseen
## TODO: Hapon tuhoutumiselle ja torjumiselle animaatio

const NOPEUS = 165
const DAMAGE = 1

## Perhonen, joka hapon ampui
var perhonen = null
## Onko happo jo kerran kimmotettu
var kimmotettu = false

func _physics_process(delta):
	# Tuhotaan happo, jos se osuu seinään tai pelaajaan.
	# Pelaajaan osuessa vähennetään elämiä, jos kilpi ei ole esillä.
	var collision = move_and_collide(velocity * NOPEUS * delta)
	if collision:
		var collider = collision.get_collider()
		var kilpi_esilla = false
		if collider is Pelaaja:
			if perhonen and collider.kilpi_esilla() and not kimmotettu:
				kilpi_esilla = true
				velocity = collider.global_position.direction_to(get_global_mouse_position())
				kimmotettu = true
			else:
				collider.meneta_elamia(DAMAGE, "normaali")

		if not kilpi_esilla:
			self.queue_free()
