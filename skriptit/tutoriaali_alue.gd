extends Area2D
## Vaihtoehtoinen toteutus sille, että tutoriaalikentän valot
## olisivat estämässä pimeyskuoleman, tuntuivat toimivan hyvin huonosti
## varmaan koska stackaavat päällekäin pakosti
## Juuso 29.10.2024


var tween: Tween

const ANIMAATION_KESTO = 1.0


func _on_body_entered(body) -> void:
	# Nämä awaitit rikkoivat toiminnallisuuden, reuna valo ei mennyt pois
	# mutta pimeyskuolema meni, hyvin outoa
	#await Globaali.maailma.ready
	if body is Pelaaja:
		Globaali.maailma.pimeyskuolema_paalla = false

		# Määrää tutoriaalialueen kirkkauden
		Globaali.maailma.pelaaja.pimea_valo.energy = 0.4

		Globaali.maailma.pelaaja.pointlight2d.energy = 1.0
		print_debug("PIMEYSKUOLEMA --- FALSE")


func _on_body_exited(body) -> void:
	#await Globaali.maailma.ready
	if body is Pelaaja:
		if tween:
			tween.kill()
		tween = create_tween().set_parallel(true)

		Globaali.maailma.pimeyskuolema_paalla = true
		tween.tween_property(Globaali.maailma.pelaaja, "pimea_valo:energy", 1.0, ANIMAATION_KESTO)
		tween.tween_property(Globaali.maailma.pelaaja, "pointlight2d:energy", 0.4, ANIMAATION_KESTO * 2.0)
		print_debug("PIMEYSKUOLEMA --- TRUE")
