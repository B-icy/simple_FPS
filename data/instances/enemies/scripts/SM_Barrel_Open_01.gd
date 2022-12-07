extends Spatial

##########################################################
# Constants
var health = 50

##########################################################
# Functions

# reduce health
func take_damage(damage):
	health -= damage
	
	if health < 0:
		queue_free()
