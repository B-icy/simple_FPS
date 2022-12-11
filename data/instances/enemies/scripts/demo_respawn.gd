extends Node

var spawn_locations = [Vector3(0, 3, -15), Vector3(-14, 3, -4), Vector3(8, 3, -30), Vector3(-20, 3, -20)]

onready var soldier = preload("res://data/instances/enemies/soldier2.tscn")

func _physics_process(delta):
	if get_child_count() == 0:
		for i in spawn_locations:
			spawn_soldier(i)

# spawn soldier in location given
func spawn_soldier(loc):
	var instance = soldier.instance()
	instance.transform.origin = loc
	add_child(instance)
