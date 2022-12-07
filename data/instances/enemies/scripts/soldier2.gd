extends Spatial

##########################################################
# Constants
var health = 30
var shape = null

##########################################################
# Functions

func _physics_process(delta):
	$AnimationPlayer.play("run")

# reduce health
func take_damage(damage):
	health -= damage
	
	if health <= 0:
		queue_free()

