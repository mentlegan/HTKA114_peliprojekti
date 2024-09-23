extends CPUParticles2D
## Valopallon partikkelit
# Juuso 23.9.2024

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true


## Kun kaikki partikkelit ovat pelanneet loppuun
func _on_finished() -> void:
	queue_free()
