extends CanvasLayer

var particles = preload("res://data/instances/particles/Bullet_Effect.tscn")

func _ready():
	var instance = particles.instance()
	instance.transform.origin = Vector3(5,0,5)
	instance.emitting = true
	get_tree().get_root().call_deferred("add_child", instance)
