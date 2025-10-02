extends CharacterBody2D
## TODO: Pelaajalle kilpi hapon torjumiseen
## TODO: Hapon tuhoutumiselle ja torjumiselle animaatio


const NOPEUS = 165
const DAMAGE = 1


func _physics_process(delta):
	# Tuhotaan happo, jos se osuu seinään tai pelaajaan.
	# Pelaajaan osuessa vähennetään elämiä.
	var collision = move_and_collide(velocity * NOPEUS * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Pelaaja:
			collider.meneta_elamia(DAMAGE, "normaali")
		self.queue_free()