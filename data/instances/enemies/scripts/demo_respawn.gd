extends Node

var spawn_locations = [Vector3(0, 10, -15), Vector3(-14, 10, -4), Vector3(8, 10, -30), Vector3(-20, 10, -20)]

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
