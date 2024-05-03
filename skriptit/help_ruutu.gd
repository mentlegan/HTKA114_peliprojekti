extends Control

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## PC F1
func _process(_delta):
	if Input.is_action_just_pressed("help"):
		self.visible = not self.visible
		get_tree().paused = self.visible
		animated_sprite.play("default")
