extends Spatial

func _ready():
	for i in get_children():
		i.create_trimesh_collision()
		i.get_child(0).collision_layer = 3
		i.get_child(0).collision_mask = 3
