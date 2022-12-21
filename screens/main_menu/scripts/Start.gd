extends Button

##########################################################
# Constants



##########################################################
# Functions

func _process(delta):
	if pressed:
		get_tree().change_scene("res://screens/lobby_select/Lobby.tscn")
