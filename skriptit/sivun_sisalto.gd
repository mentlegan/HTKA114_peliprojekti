extends Control
class_name SivunSisalto


@onready var piilota_node = $Piilota


func _ready():
	piilota_node.queue_free()
