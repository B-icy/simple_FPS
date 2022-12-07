extends Spatial

##########################################################
# Constants
var health = 50

onready var explosion = $CPUParticles

##########################################################
# Functions

# emit explosions on spawn to reduce lag
func _ready():
	explosion.emitting = true

# reduce health and place particles
func take_damage(damage, location):
	health -= damage
	explosion.emitting = true
	explosion.global_transform.origin = location
	explosion.direction = location.normalized()
	
	if health < 0:
		queue_free()
