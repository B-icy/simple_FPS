extends StaticBody

##########################################################
# Constants

onready var parent = $"../../../.."

##########################################################
# Functions

func _ready():
	add_to_group("enemy")


func take_damage(damage):
	parent.health -= damage
	
	if parent.health <= 0:
		parent.queue_free()
