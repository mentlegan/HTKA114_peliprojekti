extends Polygon2D

@export var taso = 1
var nopeusEro = 0.2
@onready var pelaaja = $"../../Pelaaja"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = -pelaaja.get_global_position() * taso * nopeusEro
