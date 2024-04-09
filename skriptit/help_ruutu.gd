extends Control


func _process(_delta):
	if Input.is_action_just_pressed("help"):
		self.visible = not self.visible
		get_tree().paused = self.visible
