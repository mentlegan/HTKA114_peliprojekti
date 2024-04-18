extends Sprite2D

@export var taso = 1
var nopeusEro = 0.1
@onready var pelaaja = $"../../../Pelaaja"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = -pelaaja.position.x * taso * nopeusEro
