extends Area2D
## Nopea tapa siirtää vedenpintaa
## Juuso 26.9.2024

@export var siirrettava: Vesi2D
var aktiivinen = true

@export var tooltip: Tooltip

func aktivoi():
	if siirrettava and aktiivinen:
		aktiivinen = false
		siirrettava.aseta_vedenpinta_seuraavaan_merkkiin()
		if tooltip:
			tooltip.deaktivoi()
