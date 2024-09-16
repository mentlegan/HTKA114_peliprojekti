## Harri 16.9.2024
## Käsitellään tutoriaalin avaavaa nodea. Tehty lähinnä nimen tarkistuksen takia
extends Area2D


## Ready tapahtuu, kun scene avautuu
func _ready():
	pass


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
		Globaali.unlock_tutorial(self.name)
		#Globaali.unlock_tutorial(self.name.rstrip("2")) # So far meillä oli vain yksi tapaus, jossa tutoriaalin voi avata kahdesta paikasta
