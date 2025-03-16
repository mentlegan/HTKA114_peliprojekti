@tool
extends Perhonen
class_name PerhonenKuljettava
## Kuljettava perhonen
## Nykyinen toteutus:
## Pelaajan tulee painaa F perhosen valon alueella, jotta hyppää kyytiin
## Pois pääsee samalla näppäimellä
## Juuso 16.3.2025

## Kuljettavan perhosen eri luokat, saa nähdä tuleeko enempää
enum Luokka {
	NORMAALI, ## Liikkuu jatkuvasti riippumatta onko kyydissä
	ODOTTAVA, ## Odottaa pelaajan hyppäämistä kyytiin ennen kuin liikkuu
}

## Setteri export muuttujalle, päivittää nyt heti labelin tekstin editorissa
@export var luokka: Luokka = Luokka.NORMAALI:
	set(value):
		luokka = value
		if not Engine.is_editor_hint():
			return
		if not is_inside_tree():
			await self.ready
		paivita_label_text()

## Testausta varten luokka näkymään perhosen päällä
@onready var label_luokka: Label = $LabelLuokka

## Viite pelaajaan
var pelaaja: Pelaaja

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super._ready()
	paivita_label_text()
	#self.z_index = -1 ## Pelaaja perhosen eteen


func paivita_label_text() -> void:
	label_luokka.text = str(Luokka.find_key(luokka)).to_pascal_case()


func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		#pelaaja = body
		pass


func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		if luokka == Luokka.NORMAALI:
			pelaaja = null


## Liikuttaa pelaajaa omaan nykyiseen sijaintiin
## Hoitaa pelaajan kääntämisen
func liikuta_pelaajaa() -> void:
	pelaaja.global_position = self.global_position
	# Velocityn asettaminen nollaan taitaa korjata turhan töminän kyydissä
	pelaaja.velocity = Vector2.ZERO
	# Vaihdetaan kääntäminen juuri päinvastaiseen suuntaan
	# Pelaaja katsoo alustavasti oikealle, mutta perhonen vasemmalle
	pelaaja.animaatio.set_flip_h(not self.animaatio.is_flipped_h())
	#print("Vanha ddeltava x: ", vanha_edeltava_x)
	#print("Path follow: ", path_follow_2d.position.x)


## Käytetään hyväksi polymorfismia
## Tätä siis kutsutaan silloin, kun kutsutaan super._physics_process()
## ja siellä olevaa laske_etaisyys()
func laske_etaisyys(delta: float) -> void:
	# Lasketaan etäisyys normaalisti
	super.laske_etaisyys(delta)
	# Rajoitetaan etäisyys nollan ja yhden välille, sillä path2d on jana
	if luokka == Luokka.ODOTTAVA:
		etaisyys = clampf(etaisyys, 0.0, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if luokka == Luokka.NORMAALI:
		# Itsensä liikuttaminen
		super._physics_process(delta)
		# Pelaajan käsittely
		if pelaaja:
			liikuta_pelaajaa()
	else: # ODOTTAVA
		#print(path_follow_2d.progress_ratio)
		if pelaaja:
			liikuta_pelaajaa()
			# Jos ei olla lopussa
			if not is_zero_approx(path_follow_2d.progress_ratio - 1.0):
				super._physics_process(delta)
		# Jos ei ole kyydissä ja ei olla alussa
		elif not is_zero_approx(path_follow_2d.progress_ratio):
				# Taaksepäin -deltan avulla
				super._physics_process(-delta)
