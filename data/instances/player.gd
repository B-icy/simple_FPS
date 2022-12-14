extends KinematicBody

##########################################################
# Constants

export var speed = 20
export var gravity = 2.18
export var damage = 5

var velocity = Vector3.ZERO
var mouse_sensitivity = 0.025
var jump_strength = 50
var jump_decay = 0.95
var health = 100
var current_weapon = 0
var ammo_holds = [12, 25, 0]
var weapon_damage = [8, 5, 20]
var weapon_movespeed = [1.1, 1, 1.3]
var walk_accel_base = 0.6

var _jump_amount = 0
var _can_double_jump = false
var _weapon_count = 3
var _current_ammo = [12, 25, 0]
var _total_ammo = [100, 300, 0]
# modifier so that when you're standing still and start moving, slowly ramp into full speed
var _walk_accel = walk_accel_base

onready var raycast = $Head/Camera/RayCast
onready var ammo_count = $Head/Camera/Ammo_Count
onready var total_ammo_count = $Head/Camera/TotalAmmo
onready var particles = preload("res://data/instances/particles/Bullet_Effect.tscn")
onready var fps_counter = $Head/Camera/FPS
onready var health_label = $Head/Camera/Health
onready var weapon_list = [$Head/Weapons/Pistol, $Head/Weapons/AK47, $Head/Weapons/knife]
onready var current_weapon_sprite = weapon_list[0]
onready var current_ammo_sprite = [$Head/Camera/Ammo_Icon, $Head/Camera/Ammo_Icon_AK, $Head/Camera/Ammo_Icon_AK]

##########################################################
# Functions

# called every physics instance
func _physics_process(delta):
	# exit application when esc is pressed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	# update fps counter
	fps_counter.set_text("FPS " + String(Engine.get_frames_per_second()))
	
	# change weapon logic
	if Input.is_action_just_pressed("change_weapon_down"):
		_change_weapon("down")
	elif Input.is_action_just_pressed("change_weapon_up"):
		_change_weapon("up")
	
	# fire if mouse button is pressed (semi auto for pistol and knife, full auto for ak
	if Input.is_action_just_pressed("ui_fire") and (current_weapon == 0 or current_weapon == 2):
		_fire()
	elif Input.is_action_pressed("ui_fire") and current_weapon == 1:
		_fire()
	
	# lock mouse and make it invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# check if reloading
	if Input.is_action_pressed("reload"):
		_reload()
	
	# call the movement function
	_move(delta)

# wasd movement controller
func _move(delta):
	# local variable for travel direction
	var direction = Vector3.ZERO
	
	# add acceleration when switching directions
	
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
		$Head/multiplayer_char.body.play("running")
		_walk_accel = min(1, _walk_accel + delta)
	else:
		$Head/multiplayer_char.body.play("RESET")
		_walk_accel = walk_accel_base
	
	# apply movement to character
	var speed_modifier = speed * weapon_movespeed[current_weapon] * _walk_accel
	velocity.x = direction.x * speed_modifier
	velocity.y -= gravity
	velocity.z = direction.z * speed_modifier
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# reset double jump if on floor
	if is_on_floor():
		_can_double_jump = true
	
	# handle jump seperately
	if Input.is_action_pressed("ui_accept"):
		_jump()
	_jump_smoothing()

# hand jump movement
func _jump():
	if is_on_floor():
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
	# if current ammo is > 0 and there is no weapon animation playing or if on knife
	if (int(ammo_count.text) > 0 and $AnimationPlayer.current_animation == "") or (current_weapon == 2 and $AnimationPlayer.current_animation == ""):
		# update ammo text, note text must be string hence conversion
		_current_ammo[current_weapon] -= 1
		ammo_count.text = str(int(ammo_count.text) - 1)
		# play fire animation
		if current_weapon == 0:
			$AnimationPlayer.play("fire_pistol")
			$Head/multiplayer_char.hands.play("fire_pistol")
		elif current_weapon == 1:
			$AnimationPlayer.play("fire_ak")
		elif current_weapon == 2:
			$AnimationPlayer.play("fire_knife")
		
		# test if ray cast is colliding with an object 
		# adjust length of vector based off weapon selected
		if current_weapon == 2:
			raycast.cast_to = Vector3(0, 0, -5)
		else:
			raycast.cast_to = Vector3(0, 0, -1000)
		if raycast.is_colliding():
			var location = raycast.get_collision_point()
			var target = raycast.get_collider()
			_bullet_effect(location)
			
			if target.is_in_group("enemy"):
				target.take_damage(weapon_damage[current_weapon])
	
	# if trying to shoot and no ammo
	elif $AnimationPlayer.current_animation == "" and Input.is_action_just_pressed("ui_fire"):
		$AnimationPlayer.play("out_pistol")

# play bullet effect, add particle effect to location
func _bullet_effect(location):
	var instance = particles.instance()
	instance.transform.origin = location
	instance.emitting = true
	get_tree().get_root().add_child(instance)

# update bullet labels
func _update_ammo_labels():
	ammo_count.text = str(_current_ammo[current_weapon])
	total_ammo_count.text = "/ " + str(_total_ammo[current_weapon])
	for i in current_ammo_sprite:
		i.visible = false
	current_ammo_sprite[current_weapon].visible = true

# reload logic
func _reload():
	# check if already doing another animation and if current ammo doesnt equal max ammo
	if $AnimationPlayer.current_animation == "" and _current_ammo[current_weapon] != ammo_holds[current_weapon]:
		if current_weapon == 0:
			$AnimationPlayer.play("reload_pistol")
			$Head/multiplayer_char.hands.play("reload_pistol")
		if current_weapon == 1:
			$AnimationPlayer.play("reload_ak")

# called by animation player
func _reload_anim():
	var ammo_difference = min(_total_ammo[current_weapon] - (ammo_holds[current_weapon] - _current_ammo[current_weapon]), _total_ammo[current_weapon])
	_current_ammo[current_weapon] = min(ammo_holds[current_weapon], _total_ammo[current_weapon] + _current_ammo[current_weapon])
	_total_ammo[current_weapon] = max(ammo_difference, 0)
	_update_ammo_labels()

# taking damage
func take_damage(damage):
	health -= damage
	health_label.text = str(health)

# change weapon function
func _change_weapon(direction):
	# if an animation is playing, stop weapon change
	if $AnimationPlayer.current_animation != "":
		return
	
	if direction == "up":
		current_weapon = (current_weapon + 1) % _weapon_count
	elif direction == "down":
		current_weapon = (current_weapon - 1) % _weapon_count
		if current_weapon < 0:
			current_weapon = _weapon_count - 1
	
	# set current weapon 
	current_weapon_sprite.visible = false
	current_weapon_sprite = weapon_list[current_weapon]
	current_weapon_sprite.visible = true
	
	_update_ammo_labels()
	

# pickup other items
func _on_Area_area_entered(area):
	if area.is_in_group("akammo"):
		_total_ammo[1] += 25
		_update_ammo_labels()
		area.get_parent().get_parent().queue_free()
