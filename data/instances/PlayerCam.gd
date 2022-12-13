extends Camera

##########################################################
# Constants

var count = 5

##########################################################
# Functions

func _process(delta):
	get_tree().call_group("mirrors", "update_cam", global_transform)
	count -= delta
	if count < 0:
		$Intro.visible = false
		
func _ready():
	pass
