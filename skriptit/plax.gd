extends Sprite2D

@export var taso = 1
var nopeusEro = 0.02
@onready var pelaaja = $"../../../Pelaaja"

# Liikutetaan taustoja eri nopeuksilla pelaajaan verrattuna
func _process(_delta):
	position.x = -pelaaja.position.x * taso * nopeusEro
