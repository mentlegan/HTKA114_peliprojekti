extends Area2D
class_name PotioninOsa
## Potionin osa, jonka pelaaja voi kerätä. Kuuluu ryhmään potionin_osa.
## Keräämisen jälkeen potion poistuu sekä scenestä että ryhmästä.
## Kun ryhmässä ei ole enää jäseniä, kaikki osat on kerätty.
## 28.10.2024 Sprite tekstuuri exporttina, pieni idle liike
## Juuso 28.10.2024

@export var sprite_texture: CompressedTexture2D = preload("res://addons/rmsmartshape/assets/icon_editor_handle_selected.svg")

## Keräysanimaation kesto
const ANIMAATION_KESTO = 2

## Y-koordinaatti pientä "pomppuilua" varten
var starting_y: float

## Valo
@onready var pointlight = $PointLight2D

## Äänet
@onready var audio_potionin_osa = $AudioPotioninOsa

func _ready():
	# Pelin alussa lisää itsensä potionin_osa-ryhmään
	add_to_group("potionin_osa")
	$Sprite2D.texture = sprite_texture
	starting_y = self.global_position.y
	await get_tree().create_timer(randf_range(0, 1)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_loops(0)
	tween.tween_property(self, "global_position:y", starting_y + randi_range(-10, -15), 
		ANIMAATION_KESTO + randf_range(-0.5, 0.5)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", starting_y + randi_range(0, 5), 
		ANIMAATION_KESTO + randf_range(-0.5, 0.5)).set_ease(Tween.EASE_OUT)


## Kerää ja tuhoaa osan. Palauttaa, kuinka monta osaa on vielä keräämättä.
func keraa() -> int:
	# Ei kerätä uudestaan, kun keräämisanimaatio on käynnissä
	remove_from_group("potionin_osa")
	if not audio_potionin_osa.playing:
		audio_potionin_osa.play()
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "modulate:a", 0, ANIMAATION_KESTO)
	tween.tween_property(self, "global_position:y", -40, ANIMAATION_KESTO).as_relative()
	tween.tween_property(pointlight, "texture_scale", 0, ANIMAATION_KESTO)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
	
	return get_tree().get_nodes_in_group("potionin_osa").size()
