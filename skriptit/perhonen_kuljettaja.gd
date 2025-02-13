extends Perhonen
class_name PerhonenKuljettaja
## Kuljettava perhonen
## Nykyinen toteutus:
## Pelaajan tulee painaa F perhosen valon alueella, jotta hyppää kyytiin
## Pois pääsee samalla näppäimellä
## Juuso 13.2.2025

var pelaaja: Pelaaja

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#self.z_index = -1 ## Pelaaja perhosen eteen


func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		#pelaaja = body
		pass


func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Itsensä liikuttaminen
	super._physics_process(delta)
	# Pelaajan käsittely
	if pelaaja:
		liikuta_pelaajaa()
