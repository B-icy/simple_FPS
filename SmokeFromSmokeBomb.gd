extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	 # Replace with function body.
	scale.x = 0.1;
	scale.y = 0.1;
	scale.z = 0.1;
	
func _process(delta):
	
	if scale.x < 3 || scale.y < 3 ||scale.z < 3:
		scale.x = 1.1*scale.x
		scale.y = 1.1*scale.y
		scale.z = 1.1*scale.z
	else:
		scale.x = 15
		scale.y = 15
		scale.z = 15
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
