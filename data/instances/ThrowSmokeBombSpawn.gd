extends Spatial

################################################

onready var main = get_tree().current_scene
#onready var spawnpoint = get_node("../SmokeBomb")
var smokescreen = preload("res://SmokeBomb.tscn")
export var numberofsmokes = 5.0;

################################################

func _physics_process(delta):
	if Input.is_action_just_pressed("smokebomb") and numberofsmokes > 0:
		_loadsmokebomb()
		numberofsmokes = numberofsmokes - 1;


func _loadsmokebomb():
	var smokescreencopy = smokescreen.instance()
	smokescreencopy.global_transform.origin = get_parent().global_transform.origin
	get_tree().current_scene.add_child(smokescreencopy)
	yield(get_tree().create_timer(2.0), "timeout")
