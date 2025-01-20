extends Area2D
## Vaihtoehtoinen toteutus sille, että tutoriaalikentän valot
## olisivat estämässä pimeyskuoleman, tuntuivat toimivan hyvin huonosti
## varmaan koska stackaavat päällekäin pakosti
## Juuso 29.10.2024

const ANIMAATION_KESTO = 1.0

var tween: Tween

func _on_body_entered(body) -> void:
	# Nämä awaitit rikkoivat toiminnallisuuden, reuna valo ei mennyt pois
	# mutta pimeyskuolema meni, hyvin outoa
	#await Globaali.maailma.ready
	if body is Pelaaja:
		Globaali.maailma.pimeyskuolema_paalla = false
		
		# Määrää tutoriaalialueen kirkkauden
		Globaali.maailma.pelaaja.pimea_valo.energy = 0.6
		
		# Tason reunat näkymään tutoriaalissa
		Globaali.maailma.pelaaja.reunojen_pimentaja_valo.blend_mode = PointLight2D.BLEND_MODE_MIX
		
		# Oletusarvolla pelaajan himmeä valo pimentää ympäristöä, joten asetetaan se yhteen
		Globaali.maailma.pelaaja.pointlight2d.energy = 1.0
		
		print_debug("PIMEYSKUOLEMA --- FALSE")


func _on_body_exited(body) -> void:
	#await Globaali.maailma.ready
	if body is Pelaaja:
		if tween:
			tween.kill()
		tween = create_tween().set_parallel(true)
	
		Globaali.maailma.pimeyskuolema_paalla = true
		Globaali.maailma.pelaaja.reunojen_pimentaja_valo.blend_mode = PointLight2D.BLEND_MODE_SUB
		Globaali.maailma.pelaaja.reunojen_pimentaja_valo.energy = 0
		tween.tween_property(Globaali.maailma.pelaaja, "pimea_valo:energy", 1.0, ANIMAATION_KESTO)
		tween.tween_property(Globaali.maailma.pelaaja, "reunojen_pimentaja_valo:energy", 1.0, ANIMAATION_KESTO)
		tween.tween_property(Globaali.maailma.pelaaja, "pointlight2d:energy", 0.4, ANIMAATION_KESTO)
		print_debug("PIMEYSKUOLEMA --- TRUE")
