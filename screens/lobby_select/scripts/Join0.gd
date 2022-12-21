extends Button

##########################################################
# Constants



##########################################################
# Functions

func _process(delta):
	if pressed:
		get_tree().change_scene("res://data/maps/testmap3/MapThreeScene.tscn")
