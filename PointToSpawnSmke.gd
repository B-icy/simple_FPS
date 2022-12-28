extends Spatial


onready var main = get_tree().current_scene
#onready var spawnpoint = get_node("../SmokeBomb")
var smokespawn = load("res://SmokeFromSmokeBomb.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_loadsmoke()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	pass

func _loadsmoke():
	yield(get_tree().create_timer(5.0), "timeout")
	
	var smokecopy = smokespawn.instance()
	main.add_child(smokecopy)
	smokecopy.transform = global_transform
	
	
