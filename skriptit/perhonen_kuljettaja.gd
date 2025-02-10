extends Perhonen
class_name PerhonenKuljettaja
## Kuljettava perhonen
## Juuso 10.2.2025

var pelaaja: Pelaaja

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#self.z_index = -1 ## Pelaaja perhosen eteen


func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		#pelaaja = body
		print("ez")
		pass


func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		pelaaja = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Liikuttaminen
	super._physics_process(delta)
	if pelaaja:
		print("on")
		pelaaja.global_position = self.global_position
		pelaaja.animaatio.set_flip_h(edeltava_x < path_follow_2d.position.x)
