extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if (Input.is_action_pressed("pause")):
		if not get_tree().is_paused():
			$"ColorRect".show()
			get_tree().set_pause(true)
		else:
			$"ColorRect".hide()
			get_tree().set_pause(false)
		

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
