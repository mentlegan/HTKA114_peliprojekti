## Paavo 22.4.2024
## Skripti oven indikaattorille


extends CPUParticles2D


func _ready():
	# Ei aloiteta partikkelin animaatiota alusta
	one_shot = true
	emitting = false


## Laittaa oven indikaattorin näkyviin. Menee pois päältä itsestään
func aloita():
	emitting = true
