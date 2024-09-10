## Harri 10.9.2024
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


## Otetaan merkkijono viimeinen merkki, ja katsotaan, että onko se numero vai ei, ja otetaan se pois, jos on
## Work in progress, tätä voisi muokata toimivammaksi kun näkee tarpeen
func parseString(string) -> String:
	var pituus = string.length() + 1
	for n in pituus:
		string.rstrip(str(n))
	return string


## Kun pelaaja osuu tutoriaalin unlockaavaan alueeseen
func _on_body_entered(body):
	if body is Pelaaja:
		#Globaali.unlock_tutorial(parseString(self.name))
		Globaali.unlock_tutorial(self.name.rstrip("2")) # So far meillä on vain yksi tapaus, jossa tutoriaalin voi avata kahdesta paikasta
