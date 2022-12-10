extends Spatial

##########################################################
# Constants

onready var hands = $hands
onready var body = $body

##########################################################
# Functions

func _physics_process(delta):
	if $body.current_animation == "" or $body.current_animation == "running":
		$Cube002.transform.rotated(Vector3.UP, 0)
		$Cube001.transform.rotated(Vector3.UP, 0)
