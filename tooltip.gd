extends Sprite2D


const OFFSET_MAX = 15
const OFFSET_SPEED = 15
var offset_target = 0


func _ready():
	offset_target = OFFSET_MAX
	offset.y = OFFSET_MAX
	modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset.y += (offset_target - offset.y) * delta * OFFSET_SPEED
	modulate.a = 1 - (offset.y / OFFSET_MAX)


## Asetetaan tooltip näkyviin, kun pelaaja astuu sen alueelle
func _on_area_2d_body_entered(body):
	if body is Pelaaja:
		offset_target = 0


## Piilotetaan tooltip, kun pelaaja poistuu sen alueelta
func _on_area_2d_body_exited(body):
	if body is Pelaaja:
		offset_target = OFFSET_MAX
