extends Area2D
class_name MyrkkyAlue2D

## Editorissa vaihdettava arvo sille, ottaako myrkystä damagea
@export var tekeeko_damagea: bool = true
#@onready var myrkky_audio = $AudioMyrkkyalue

## Animoitu texture myrkkyalueelle
const MYRKYN_TEXTURE = preload("res://resurssit/vesi/myrkkyalue.tres")

## Annetaan myrkkyalueen lapsena oleville polygoneille haluttu ulkonäkö, ja luodaan niille saman kokoiset collisionshapet
func _ready() -> void:
	for lapsi in get_children():
		if lapsi is Polygon2D:
			var myrkkyalue_collision = CollisionPolygon2D.new()
			lapsi.texture = MYRKYN_TEXTURE
			lapsi.modulate.a = 0.7
			lapsi.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			myrkkyalue_collision.polygon = lapsi.polygon
			add_child(myrkkyalue_collision)


## Pelaajan alkaa ottamaan myrkkyä tullessaan alueelle
func _on_body_entered(body):
	#myrkky_audio.play()
	if tekeeko_damagea:
		if body.is_in_group("Pelaaja"):
			body.myrkkyalue_timer()
			body.myrkkyalue_ajastin.one_shot = false


## Lopetetaan myrkyn jatkuminen kun pois alueelta
func _on_body_exited(body):
	#myrkky_audio.stop()
	if tekeeko_damagea:
		if body.is_in_group("Pelaaja"):
			body.myrkkyalue_ajastin.one_shot = true
