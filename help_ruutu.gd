extends Control


func _process(_delta):
	if (Input.is_action_just_pressed("help")
	or Input.is_action_just_pressed("abxy_oikea")):
		self.visible = not self.visible
		get_tree().paused = self.visible
