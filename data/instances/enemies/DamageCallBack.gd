extends StaticBody

##########################################################
# Constants

onready var parent = $"../../../.."
onready var akammo = preload("res://data/instances/pickups/ak_ammo.tscn")

##########################################################
# Functions

func _ready():
	add_to_group("enemy")


func take_damage(damage):
	parent.health -= damage
	
	if parent.health <= 0:
		var instance = akammo.instance()
		instance.global_transform.origin = parent.global_transform.origin
		get_tree().get_root().add_child(instance)
		parent.queue_free()
