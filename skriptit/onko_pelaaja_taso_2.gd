extends Area2D
## Kun pelaaja saapuu vesialueelle
## Voi piilottaa editorissa, ei vaikutusta
## Juuso 25.9.2024


func _on_body_entered(body) -> void:
	if body is Pelaaja:
		# Tarvitaan koska teleportatessa muutetaan
		if body.process_mode == Node.PROCESS_MODE_INHERIT:
			Globaali.maailma.tausta2_node.show()
			Globaali.maailma.tausta_node.hide()


func _on_body_exited(body) -> void:
	if body is Pelaaja:
		if body.process_mode == Node.PROCESS_MODE_INHERIT:
			Globaali.maailma.tausta_node.show()
			Globaali.maailma.tausta2_node.hide()
