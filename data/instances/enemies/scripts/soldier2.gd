extends KinematicBody

##########################################################
# Constants
var health = 30
var shape = null
var speed = 5
var velocity = Vector3.ZERO
var gravity = 9.18
var rng = RandomNumberGenerator.new()
var heading = 0

export var move = true

onready var akammo = preload("res://data/instances/pickups/ak_ammo.tscn")

##########################################################
# Functions

func ready():
	rng.randomize()
	rng.seed = get_instance_id()

func _physics_process(delta):
	# check if char should be moving
	if move:
		_move(delta)

# move script
func _move(delta):
	$AnimationPlayer.play("run")
	
	# initial direction
	var direction = Vector3(0,0,-1)
	
	# rotate char to face forward
	direction = direction.normalized().rotated(Vector3.UP, rotation.y) * speed
	
	# move char in forward direction
	direction.y -= gravity
	velocity = move_and_slide(direction, Vector3.UP)
	
	# randomly rotate the character smoothly
	heading += rng.randf_range(-0.3,0.3) * delta
	heading = clamp(heading, -delta * 2, delta * 2)
	rotate(Vector3.UP, heading)
