extends CPUParticles

##########################################################
# Constants

export var effect_time = 0.2

var _lifetime = 0

##########################################################
# Functions
func _ready():
	lifetime = effect_time
	_lifetime = lifetime

func _physics_process(delta):
	_lifetime -= delta
	if _lifetime < 0:
		queue_free()
