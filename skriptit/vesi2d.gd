extends Area2D
class_name Vesi2D
## Node, joka sisältää useita Vesialueita.
## Vedenpinta voidaan asettaa funktiolla aseta_vedenpinta(y) tai aseta_vedenpinta_merkkiin(merkki).
## Lumpeita voi lisätä asettamalla niitä Vesialueiden lapsiksi.


## Vesi2D:n Vesialue-node voi laskea oman vedenpohjansa alle, jolloin se muuttuu näkymättömäksi.
## Vesialue voi nousta oman alkuperäisen vedenpintansa ylle pelkästään, jos sen vedenpinnalla
## ei ole toista vesialuetta.
## Esim:
## 
##  y  aseta_vedenpinta(0)   |    ...(5)    |      ...(2)        |      ...(-2)
##               |           |              |                    |
## -2            V           |              |                    |    .-------.
##                           |              |                    |    |       |
##  0    .-------.           |              |                    |    |       |
##       |       |           |              |                    |    |   a   |
##  2    |   a   |           |              | .-------.          |    |       |
##       |       |--------.  |              | |   a   |xxxxxxx-. |    |       |--------.
##  4    `-------'        |  |              | `-------'        | |    `-------'        |
##             |    b     |  | .----b-----. |       |    b     | |          |     b    |
##  6          `----------'  | `----------' |       `----------' |          `----------'
##                            a deaktivoitu   b:n maksimikorkeus       a:n vedenpinta ei
##                             / näkymätön    on 3, koska x:llä    osu toiseen vesialueeseen,
##                                           merkitty pinta osuu      joten se nousee y=-2
##                                          toiseen vesialueeseen



## Vesialueiden korkein y-koordinaatti, kokonaisluvuksi pyöristettynä
var vedenpinta = null
## Vesialueiden alhaisin y-koordinaatti, kokonaisluvuksi pyöristettynä
var vedenpohja = null
## Kaikki Vesi2D:n Vesialueet
var vesialueet = []
## Vedenpinnan merkit
var vedenpinnan_merkit = []
## Ensimmäinen merkki, johon vedenpinta asetetaan aseta_vedenpinta_merkkiin()-funktiolla
var ensimmainen_merkki = null
## Seuraavan merkin indeksi, johon vedenpinta asetetaan aseta_vedenpinta_merkkiin()-funktiolla
var seuraava_merkki = 0

## Vedenpinnan muuttumisen kesto
@export var animaation_kesto: float = 10


func _ready():
	# Etsitään 
	for lapsi in get_children():
		if lapsi is Vesialue:
			vesialueet.append(lapsi)
		
		# Lisätään samalla vedenpinnan merkit
		if lapsi is Marker2D:
			vedenpinnan_merkit.append(lapsi)
	
	if vedenpinnan_merkit.size() > 0:
		ensimmainen_merkki = vedenpinnan_merkit[0]
	
	# Asetetaan veden korkein ja alhaisin piste
	for vesialue in vesialueet:
		if not vedenpinta or vedenpinta > roundi(vesialue.vedenpinta_y):
			vedenpinta = roundi(vesialue.vedenpinta_y)
		if not vedenpohja or vedenpohja < roundi(vesialue.vedenpohja_y):
			vedenpohja = roundi(vesialue.vedenpohja_y)
	
		# Tarkistetaan samalla, sisältääkö vesialue vedenpintaa
		vesialue.set_sisaltaa_vedenpintaa(sisaltaa_vedenpintaa(vesialue))


## Tarkistaa, sisältääkö annettu Vesialue vedenpintaa
func sisaltaa_vedenpintaa(vesialue):
	for toinen_vesialue in vesialueet:
		if toinen_vesialue == vesialue:
			continue
		if vesialue.osuu_vedenpintaan(toinen_vesialue):
			return false
	return true


## Asettaa vedenpinnan seuraavan merkin korkeudelle.
func aseta_vedenpinta_seuraavaan_merkkiin():
	# Ei aseteta vedenpintaa seuraavaan merkkiin, jos merkkejä ei ole
	if not vedenpinnan_merkit:
		return
	
	aseta_vedenpinta_merkkiin(vedenpinnan_merkit[seuraava_merkki])
	seuraava_merkki = (seuraava_merkki + 1) % vedenpinnan_merkit.size()


## Asettaa vedenpinnan annetun merkin korkeudelle.
## Jos funktiota kutsutaan ilman merkki-parametria,
## vedenpinta asettuu ensimmäisen Marker2D-noden korkeudelle.
func aseta_vedenpinta_merkkiin(merkki: Marker2D = ensimmainen_merkki):
	if vedenpinnan_merkit.size() == 0:
		print_debug("Vesi2D:lla (%s) ei ole Marker2D-nodeja lapsina, skipataan" % self.name)
		return
	
	aseta_vedenpinta(merkki.global_position.y)


## Asettaa vedenpinnan annettuun y-koordinaattiin.
func aseta_vedenpinta(y: float):
	for vesialue in vesialueet:
		vesialue.aseta_vedenpinta(y, animaation_kesto)
