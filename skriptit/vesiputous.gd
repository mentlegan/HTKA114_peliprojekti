## Juuso 30.8.2024
## Vesiputouksen toiminta
extends Area2D

signal transitio(mihin_tp: Vector2)

@export var mihin_tp: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for animaatio in self.get_children():
		if animaatio is AnimatedSprite2D:
			animaatio.play("default")


func _on_body_entered(body) -> void:
	if body is Pelaaja:
		transitio.emit(mihin_tp.global_position)
		self.set_collision_mask_value(2, false)
		# Teleportataan kuilun alas transitiolla, ruutu mustaksi esim.
	# Jos valopallo
	elif body.is_in_group("valopallo"):
		body.start_destroy()
