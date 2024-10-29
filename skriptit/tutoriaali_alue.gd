extends Area2D
## Vaihtoehtoinen toteutus sille, että tutoriaalikentän valot
## olisivat estämässä pimeyskuoleman, tuntuivat toimivan hyvin huonosti
## varmaan koska stackaavat päällekäin pakosti
## Juuso 29.10.2024


func _on_body_entered(body) -> void:
	if body is Pelaaja:
		Globaali.pimeyskuolema_paalla = false
		Globaali.pelaaja.reuna_valo.visible = false
		print_debug("PIMEYSKUOLEMA --- FALSE")


func _on_body_exited(body) -> void:
		if body is Pelaaja:
			Globaali.pimeyskuolema_paalla = true
			Globaali.pelaaja.reuna_valo.visible = true
			print_debug("PIMEYSKUOLEMA --- TRUE")
