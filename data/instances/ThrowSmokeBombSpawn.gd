extends Spatial


onready var main = get_tree().current_scene
#onready var spawnpoint = get_node("../SmokeBomb")
var smokescreen = load("res://SmokeBomb.tscn")
export var numberofsmokes = 5.0;


# Called when the node enters the scene tree for the first time.
func user_input():
	
	if numberofsmokes > 0:
		if Input.is_action_just_pressed("smokebomb"):
			_loadsmokebomb()
			numberofsmokes = numberofsmokes - 1;
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	pass

func _loadsmokebomb():
	var smokescreencopy = smokescreen.instance()
	smokescreencopy.global_transform.origin = global_transform.origin
	main.add_child(smokescreencopy)
	yield(get_tree().create_timer(2.0), "timeout")
	
	
