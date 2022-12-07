extends "res://data/instances/enemies/DamageCallBack.gd"


func take_damage(damage):
	parent.health -= 1.5 * damage
	
	if parent.health <= 0:
		parent.queue_free()
