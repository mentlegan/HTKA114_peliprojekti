extends Perhonen
## Healaava perhonen
## Juuso 15.11.2024

@export_group("Heal statsit")
@export var heal_maara: int = 1
@export var heal_timeout: float = 1.5

var timer: Timer

## Luo ajastimen pelaajalle, joka kutsuu elama_regen funktiota
func _on_body_entered(body: Node2D) -> void:
	if body is Pelaaja:
		timer = Timer.new()
		timer.name = "TimerHeal"
		timer.wait_time = heal_timeout
		timer.timeout.connect(body.elama_regen)
		body.add_child(timer)
		timer.start()
		print_debug(self.name, " LUOTU AJASTIN ", timer.name)
		# TODO: Healin näyttäminen visuaalisesti


## Poistetaan ajastin, kun poistutaan alueelta
func _on_body_exited(body: Node2D) -> void:
	if body is Pelaaja:
		if timer:
			timer.queue_free()
		else:
			printerr("EI LÖYTYNYT AJASTINTA", self)
