@tool
extends Perhonen
class_name PerhonenKuljettava
## Kuljettava perhonen
## Nykyinen toteutus:
## Pelaajan tulee painaa hyppynappia perhosen valon alueella, jotta hyppää kyytiin
## Pois pääsee samalla näppäimellä
## Juuso 23.12.2025

## Kuljettavan perhosen eri luokat, saa nähdä tuleeko enempää
enum Luokka {
	NORMAALI, ## Liikkuu jatkuvasti riippumatta onko kyydissä
	ODOTTAVA, ## Odottaa pelaajan hyppäämistä kyytiin ennen kuin liikkuu
	LIIK_LAIT, ## Huilulla liikkeelle laitettava
}

## Liikkelle laitettavalle
var liikkuu_eteenpain: bool = false
var tultu_alkuun: bool = false
var oliko_pelaaja_kyydissa: bool = false

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


## Vain liikkelle laitettavalle
func _on_area_entered(area: Area2D) -> void:
	if area is Huilu && area.aanen_taajuus == 2:
		if is_zero_approx(path_follow_2d.progress_ratio):
			liikkuu_eteenpain = true


## Liikkeelle laitettavan kyytiin ei pääse, jos se ei liiku
func tarkista_paaseeko_kyytiin() -> bool:
	if luokka == Luokka.LIIK_LAIT:
		return not is_zero_approx(path_follow_2d.progress_ratio)
	
	return true


## Käytetään hyväksi polymorfismia
## Tätä siis kutsutaan silloin, kun kutsutaan super._physics_process()
## ja siellä olevaa laske_etaisyys()
func laske_etaisyys(delta: float) -> void:
	# Lasketaan etäisyys normaalisti
	super.laske_etaisyys(delta)
	# Rajoitetaan etäisyys nollan ja yhden välille, sillä path2d on jana
	if luokka == Luokka.ODOTTAVA or luokka == Luokka.LIIK_LAIT:
		etaisyys = clampf(etaisyys, 0.0, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	match luokka:
		Luokka.NORMAALI:
			super._physics_process(delta)
			if pelaaja:
				liikuta_pelaajaa()
	
		Luokka.ODOTTAVA:
			if pelaaja:
				liikuta_pelaajaa()
				# Jos ei olla lopussa
				if not is_zero_approx(path_follow_2d.progress_ratio - 1.0):
					super._physics_process(delta)
			# Jos ei ole kyydissä ja ei olla alussa
			elif not is_zero_approx(path_follow_2d.progress_ratio):
					# Taaksepäin -deltan avulla
					super._physics_process(-delta)
	
		Luokka.LIIK_LAIT:
			if pelaaja:
				liikuta_pelaajaa()
			if liikkuu_eteenpain:
				if pelaaja:
					# TODO: Tässä vaiheessa tarkistetaan vielä
					# oliko ollenkaan kyydissä koko matkalla
					print("Pelaaja oli kyydissä")
					oliko_pelaaja_kyydissa = true
				
				## TODO: Väsymispiste ja hidastuminen, jos pelaaja kyydissä
				## Palaa takaisin päästyään väsymispisteeseen asti
				
				# Ollaan lopussa, asetetaan palaamaan takaisin
				if is_equal_approx(path_follow_2d.progress_ratio, 1.0):
					liikkuu_eteenpain = false
					super._physics_process(-delta)
				else:
					super._physics_process(delta)
			# Ollaan tulossa takaisin
			else:
				# Ei olla alussa, mennään takaisin alkuun
				if not is_zero_approx(path_follow_2d.progress_ratio):
					super._physics_process(-delta)
					if is_zero_approx(path_follow_2d.progress_ratio):
						tultu_alkuun = true
				elif tultu_alkuun:
					tultu_alkuun = false
					print("Alussa!")
					# Saavuttu alkuun, heitä pelaaja pois
					if pelaaja and oliko_pelaaja_kyydissa:
						oliko_pelaaja_kyydissa = false
						print("Heitetty pelaaja")
						pelaaja.perhosen_selassa = false
						pelaaja.velocity.y = -50
						pelaaja.velocity.x = 250 if animaatio.is_flipped_h() else -250
						pelaaja = null
