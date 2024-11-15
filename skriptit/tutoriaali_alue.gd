extends Area2D
## Vaihtoehtoinen toteutus sille, että tutoriaalikentän valot
## olisivat estämässä pimeyskuoleman, tuntuivat toimivan hyvin huonosti
## varmaan koska stackaavat päällekäin pakosti
## Juuso 29.10.2024


func _on_body_entered(body) -> void:
	# Nämä awaitit rikkoivat toiminnallisuuden, reuna valo ei mennyt pois
	# mutta pimeyskuolema meni, hyvin outoa
	#await Globaali.maailma.ready
	if body is Pelaaja:
		Globaali.maailma.pimeyskuolema_paalla = false
		Globaali.maailma.pelaaja.reuna_valo.visible = false
		print_debug("PIMEYSKUOLEMA --- FALSE")


func _on_body_exited(body) -> void:
	#await Globaali.maailma.ready
	if body is Pelaaja:
		Globaali.maailma.pimeyskuolema_paalla = true
		Globaali.maailma.pelaaja.reuna_valo.visible = true
		print_debug("PIMEYSKUOLEMA --- TRUE")
