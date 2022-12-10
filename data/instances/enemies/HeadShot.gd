extends "res://data/instances/enemies/DamageCallBack.gd"

##########################################################
# Constants


##########################################################
# Functions

func take_damage(damage):
	parent.health -= 1.5 * damage
	$"../../../../HeadShotSFX".play()
	
	if parent.health <= 0:
		parent.queue_free()
