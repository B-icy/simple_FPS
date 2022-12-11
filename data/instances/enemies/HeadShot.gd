extends "res://data/instances/enemies/DamageCallBack.gd"

##########################################################
# Constants


##########################################################
# Functions

func take_damage(damage):
	parent.health -= 1.5 * damage
	$"../../../../HeadShotSFX".play()
	
	if parent.health <= 0:
		var instance = akammo.instance()
		instance.global_transform.origin = parent.global_transform.origin
		get_tree().get_root().add_child(instance)
		parent.queue_free()
