extends KinematicBody

##########################################################
# Constants

export var speed = 30
export var gravity = 2.18
export var damage = 5

var velocity = Vector3.ZERO
var mouse_sensitivity = 0.025
var jump_strength = 50
var jump_decay = 0.95

var _jump_amount = 0
var _can_double_jump = false

onready var raycast = $Head/Camera/RayCast
onready var ammo_count = $Head/Camera/Ammo_Count
onready var particles = preload("res://data/instances/particles/Bullet_Effect.tscn")
onready var fps_counter = $Head/Camera/FPS

##########################################################
# Functions

# called every physics instance
func _physics_process(delta):
	# exit application when esc is pressed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	# update fps counter
	fps_counter.set_text("FPS " + String(Engine.get_frames_per_second()))
	
	# fire if mouse button is pressed
	if Input.is_action_pressed("ui_fire"):
		_fire()
	
	# lock mouse and make it invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# check if reloading
	if Input.is_action_pressed("reload"):
		_reload()
	
	# call the movement function
	_move()

# wasd movement controller
func _move():
	# local variable for travel direction
	var direction = Vector3.ZERO
	
	# check input direction and set movement vector to appropriate value
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
		
	# normalize the vector so length is always equal to 1
	# point the character at the movement direction and adjust for current rotation
	if direction != Vector3.ZERO:
		direction = direction.normalized().rotated(Vector3.UP, rotation.y)
	
	# apply movement to character
	velocity.x = direction.x * speed
	velocity.y -= gravity
	velocity.z = direction.z * speed
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# handle jump seperately
	if Input.is_action_pressed("ui_accept"):
		_jump()
	_jump_smoothing()

# hand jump movement
func _jump():
	if is_on_floor():
		_can_double_jump = true
		_jump_amount = jump_strength
		move_and_slide(jump_strength * Vector3.UP)
	elif _can_double_jump and Input.is_action_just_pressed("ui_accept"):
		_can_double_jump = false
		_jump_amount = jump_strength
		velocity.y = 0
		move_and_slide(jump_strength * Vector3.UP)

# smooth out the jump
func _jump_smoothing():
	if not is_on_floor():
		_jump_amount *= jump_decay
		move_and_slide(_jump_amount * Vector3.UP)

# camera mouse movement controller
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		$Head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		$Head.rotation.x = clamp($Head.rotation.x, deg2rad(-89), deg2rad(89))

# fire weapon
func _fire():
	# if current ammo is > 0 and there is no weapon animation playing
	if int($Head/Camera/Ammo_Count.text) > 0 and $AnimationPlayer.current_animation == "":
		# update ammo text, note text must be string hence conversion
		$Head/Camera/Ammo_Count.text = str(int($Head/Camera/Ammo_Count.text) - 1)
		# play fire animation
		$AnimationPlayer.play("fire_pistol")
		
		# test if ray cast is colliding with an object
		if raycast.is_colliding():
			var location = raycast.get_collision_point()
			var target = raycast.get_collider()
			_bullet_effect(location)
			
			if target.is_in_group("enemy"):
				target.take_damage(damage)
	
	# if trying to shoot and no ammo
	elif $AnimationPlayer.current_animation == "" and Input.is_action_just_pressed("ui_fire"):
		$AnimationPlayer.play("out_pistol")

# play bullet effect, add particle effect to location
func _bullet_effect(location):
	var instance = particles.instance()
	instance.transform.origin = location
	instance.emitting = true
	get_tree().get_root().add_child(instance)

# reload logic
func _reload():
	# check if already doing another animation
	if $AnimationPlayer.current_animation == "" and ammo_count.text != "12":
		$AnimationPlayer.play("reload_pistol")
