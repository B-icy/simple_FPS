extends Button

##########################################################
# Constants



##########################################################
# Functions

func _process(delta):
	if pressed:
		get_tree().quit()
