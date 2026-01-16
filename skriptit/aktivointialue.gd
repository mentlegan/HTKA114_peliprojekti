extends Area2D

## Perhonen, joka (de)aktivoidaan pelaajan tullessa alueelle
@export var perhonen: PerhonenAmpuja = null
## Deaktivoiko alue perhosen aktivoimisen sijaan
@export var deaktivoiva = false


## (De)aktivoidaan valittu perhonen, kun pelaaja tulee alueelle
func _on_body_entered(body):
	if perhonen and body is Pelaaja:
		if deaktivoiva:
			perhonen.deaktivoi(Globaali.maailma.pelaaja)
		else:
			perhonen.aktivoi(Globaali.maailma.pelaaja)