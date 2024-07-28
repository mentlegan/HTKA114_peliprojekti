extends Area2D
class_name Vesi2D


## Vedenpinnan Sprite2D
@export var vedenpinta: Sprite2D


## Vesialueen CollisionShape2D, määrittää missä ja kuinka korkealla vesi on.
var collision_shape: CollisionShape2D = null
## Vedenkorkeuden maksimiarvo, asetetaan vastaamaan collision_shape:n korkeutta.
var max_korkeus = 0
## Vedenpohjan y-koordinaatti
var vedenpohja_y = 0


func _ready():
	# Etsitään vesialueen lapsista CollisionShape2D.
	for lapsi in get_children():
		if lapsi is CollisionShape2D:
			collision_shape = lapsi
	
	# Jos vesialuetta ei löydy, luodaan uusi CollisionShape2D.
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
	
	# Asetetaan vedenkorkeuden maksimiarvo
	max_korkeus = collision_shape.shape.size.y
	
	# Asetetaan vedenpinta näkyviin ja asetetaan sen leveys ja sijainti
	vedenpinta.visible = true
	vedenpinta.region_rect.size = Vector2(collision_shape.shape.size.x, vedenpinta.texture.diffuse_texture.get_height())
	vedenpinta.global_position = collision_shape.global_position
	
	# Asetetaan vedenpohjan y-koordinaatti
	vedenpohja_y = collision_shape.global_position.y + collision_shape.shape.size.y * 0.5
	
	aseta_vedenkorkeus(1)


## Asettaa vedenkorkeuden, välillä nollasta yhteen.
## Nollaan asetettuna vesialue on matalimmillaan, yhteen asetettuna korkeimmillaan.
## Vesialueen korkein mahdollinen piste määräytyy CollisionShape2D:n korkeimman pisteen mukaan.
func aseta_vedenkorkeus(korkeus: float):
	korkeus = clamp(korkeus, 0, 1)

	collision_shape.shape.size.y = korkeus * max_korkeus
	collision_shape.global_position.y = vedenpohja_y - collision_shape.shape.size.y * 0.5
	vedenpinta.global_position.y = collision_shape.global_position.y - collision_shape.shape.size.y * 0.5