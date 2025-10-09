extends Line2D
class_name Line2DPerhonen
## Healaavan perhosen heal efekti
## Juuso 9.8.2025

const PISTEIDEN_MAARA: int = 10
const AMPLITUDI: int = 10
const AALLON_PITUUS: int = 80

## Aalto efektin muodostus
## TODO: tällä hetkellä alustavaa toteutusta testailen
## Vaatii vielä säätöä, että saa kivemman muodon
func muodosta_aalto(aloitus_piste: Vector2, kohde: Vector2) -> void:
	self.clear_points()
	
	var suunta: Vector2 = aloitus_piste.direction_to(kohde)
	var pituus: float = aloitus_piste.distance_to(kohde)
	var suunta_kohtisuora = Vector2(-suunta.y, suunta.x)
	
	for i in range(PISTEIDEN_MAARA + 1):
		var t = i / float(PISTEIDEN_MAARA)
		var alku = aloitus_piste.lerp(kohde, t)
		var aalto = sin(t * pituus / AALLON_PITUUS * TAU) * AMPLITUDI
		# Lisätään piste "lokaalisti" miinustamalla aloituspiste
		add_point((alku + suunta_kohtisuora * aalto) - aloitus_piste)


## Palauttaa keskipisteen
func palauta_keskipiste() -> Vector2:
	if PISTEIDEN_MAARA % 2 == 0:
		return self.points[PISTEIDEN_MAARA / 2 - 1]

	return self.points[PISTEIDEN_MAARA / 2]
