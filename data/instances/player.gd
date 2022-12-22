extends KinematicBody

##########################################################
# Constants

export var speed = 20
export var gravity = 2.18
export var damage = 5
export var team = 0
export var respawn_location = Vector3(0, 10 ,0)
export var _can_halfscope = false

var velocity = Vector3.ZERO
var mouse_sensitivity = 0.025
var jump_strength = 50
var jump_decay = 0.95
var walk_accel_base = 0.6
var max_health = 100
var current_weapon = 0
const start_total_ammo = [100, 300, 30, 0]
const ammo_holds = [12, 25, 6, 0]
var weapon_damage = [8, 5, 20, 20]
var weapon_movespeed = [1.1, 1, 0.8, 1.3]
var scoped_in = false
var in_menu = false

var _health = max_health
var _jump_amount = 0
var _can_double_jump = false
var _weapon_count = 4
var _current_ammo = [12, 25, 6, 0]
var _total_ammo = start_total_ammo.duplicate()
var _menu_delay = .1

# modifier: when standing still and start moving, slowly ramp into full speed
var _walk_accel = walk_accel_base

# death variables
var dead = false
var death_timer = 6
var can_respawn = false
var _death_timer_count = death_timer
var invincible = false

onready var raycast = $Head/Camera/RayCast
onready var ammo_count = $Head/Camera/Ammo_Count
onready var total_ammo_count = $Head/Camera/TotalAmmo
onready var particles = preload("res://data/instances/particles/Bullet_Effect.tscn")
onready var fps_counter = $Head/Camera/FPS
onready var health_label = $Head/Camera/Health
onready var weapon_list = [$Head/Weapons/Pistol, $Head/Weapons/AK47, $Head/Weapons/dragunov, $Head/Weapons/knife]
onready var current_weapon_sprite = weapon_list[0]
onready var current_ammo_sprite = [$Head/Camera/Ammo_Icon, $Head/Camera/Ammo_Icon_AK, $Head/Camera/Ammo_Icon_AK, $Head/Camera/Ammo_Icon_Knife]
onready var menu = $Head/Camera/Menu

##########################################################
# Functions

# called once on load
func _ready():
	# reset raycast fire location
	raycast.cast_to = Vector3(0, 0, -1000)

# called every physics instance
func _physics_process(delta):
	### UI and general control functions
	
	# exit application when esc is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		open_menu()
	
	# update fps counter
	fps_counter.set_text(String(Engine.get_frames_per_second()))
	
	# don't move if dead
	if dead:
		wait_for_respawn(delta)
		return
	
	# disable movement if in menu
	if in_menu:
		menu_refresh(delta)
		return
	
	### movement and control logic
	
	# function handling all user input
	user_input()
	
	# call the movement function
	_move(delta)
	
	# check if out of bounds
	if global_transform.origin.y <= -50:
		take_damage(delta * 100)
	
	# die!
	if _health <= 0:
		die()

# handle all keyboard/controller inputs
func user_input():
	# change weapon logic
	if Input.is_action_just_pressed("change_weapon_down"):
		_change_weapon("down")
	elif Input.is_action_just_pressed("change_weapon_up"):
		_change_weapon("up")
		
	# debug purpose only, remove later!
	if Input.is_action_just_pressed("ui_focus_next"):
		take_damage(20)
	
	# run scope in function if scoping in on appropriate weapon
	if Input.is_action_just_pressed("scope_in") and current_weapon == 2:
		_scope()
	
	# fire if mouse button is pressed (semi auto for pistol and knife, full auto for ak
	if Input.is_action_just_pressed("ui_fire") and (current_weapon == 0 or current_weapon == 2 or current_weapon == 3):
		_fire()
	elif Input.is_action_pressed("ui_fire") and current_weapon == 1:
		_fire()
	
	# lock mouse and make it invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# check if reloading
	if Input.is_action_pressed("reload"):
		_reload()

# open menu
func open_menu():
	if not menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		in_menu = true
		menu.visible = true
		_menu_delay = .1

# called each frame when menu is open
func menu_refresh(delta):
	_menu_delay -= delta
	if $Head/Camera/Menu/ContinueButton.pressed or (Input.is_action_just_pressed("ui_cancel") and _menu_delay < 0):
		in_menu = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.visible = false
	if $Head/Camera/Menu/MainMenuButton.pressed:
		get_tree().change_scene("res://screens/main_menu/MainMenu.tscn")
	if $Head/Camera/Menu/ExitButton.pressed:
		get_tree().quit()

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
	# jump a little higher if holding a knife
	var jump_multiplier = 1
	if current_weapon == 3:
		jump_multiplier = 1.2
	if is_on_floor():
		_jump_amount = jump_strength * jump_multiplier
		move_and_slide(jump_strength * Vector3.UP)
	# double jump logic
	elif _can_double_jump and Input.is_action_just_pressed("ui_accept"):
		_can_double_jump = false
		_jump_amount = jump_strength * jump_multiplier
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
	# if using a knife
	if current_weapon == 3 and $AnimationPlayer.current_animation == "":
		raycast.cast_to = Vector3(0, 0, -5)
		$AnimationPlayer.play("fire_knife")
	
	# if current ammo is > 0 and there is no weapon animation playing\
	elif int(ammo_count.text) > 0 and $AnimationPlayer.current_animation == "":
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
			if scoped_in == true:
				$AnimationPlayer.play("fire_dragunov_scoped")
			else:
				$AnimationPlayer.play("fire_dragunov")
		
		# test if ray cast is colliding with an object 
		if raycast.is_colliding():
			var location = raycast.get_collision_point()
			var target = raycast.get_collider()
			_bullet_effect(location)
			
			if target.is_in_group("enemy"):
				target.take_damage(weapon_damage[current_weapon])
	
	# if trying to shoot and no ammo
	elif $AnimationPlayer.current_animation == "" and Input.is_action_just_pressed("ui_fire"):
		$AnimationPlayer.play("out_pistol")

# scope in function
func _scope():
	# check if halfscoping
	var half_scoping = $AnimationPlayer.current_animation == "fire_dragunov_scoped" and _can_halfscope
	
	# check if in a current animation or halfscoping, if thats the case exit function
	if $AnimationPlayer.current_animation != "" and not half_scoping:
		return
	
	# check which state currently in and scope in/out
	if current_weapon == 2 and $Head/Camera.fov == 70:
		$AnimationPlayer.play("scope_dragunov")
		scoped_in = true
	else:
		$AnimationPlayer.play("unscope_dragunov")
		scoped_in = false

# knife logic, called from animation player
func _knife():
	if raycast.is_colliding():
		var location = raycast.get_collision_point()
		var target = raycast.get_collider()
		_bullet_effect(location)
		
		if target.is_in_group("enemy"):
			target.take_damage(weapon_damage[current_weapon])

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
	print(_current_ammo[current_weapon])
	print(ammo_holds[current_weapon])
	print("-----------------")
	# check if already doing another animation and if current ammo doesnt equal max ammo
	if $AnimationPlayer.current_animation == "" and _current_ammo[current_weapon] != ammo_holds[current_weapon]:
		if current_weapon == 0:
			$AnimationPlayer.play("reload_pistol")
			$Head/multiplayer_char.hands.play("reload_pistol")
		if current_weapon == 1:
			$AnimationPlayer.play("reload_ak")
		if current_weapon == 2:
			$AnimationPlayer.play("reload_dragunov")

# called by animation player
func _reload_anim():
	var ammo_difference = min(_total_ammo[current_weapon] - (ammo_holds[current_weapon] - _current_ammo[current_weapon]), _total_ammo[current_weapon])
	_current_ammo[current_weapon] = min(ammo_holds[current_weapon], _total_ammo[current_weapon] + _current_ammo[current_weapon])
	_total_ammo[current_weapon] = max(ammo_difference, 0)
	_update_ammo_labels()

# taking damage
func take_damage(damage):
	if invincible:
		return
	_health -= damage
	health_label.text = str(abs(round(_health)))

# change weapon function
func _change_weapon(direction):
	# if an animation is playing, stop weapon change
	if $AnimationPlayer.current_animation != "":
		return
	
	# clear any current animation effects
	$AnimationPlayer.play("RESET")
	
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
	
	# set weapon range
	if current_weapon != 4:
		raycast.cast_to = Vector3(0, 0, -1000)
	
	_update_ammo_labels()

# called when character dies, stops movement and sets death timer
func die():
	visible = false
	
	var screen_size = OS.get_window_size()
	$Head/Camera/DeathScreen.material.set_shader_param("Screen Width", screen_size[0])
	$Head/Camera/DeathScreen.material.set_shader_param("Screen Height", screen_size[1])
	$AnimationPlayer.play("death_screen")
	# when dead is true, character can no longer move
	dead = true
	_death_timer_count = death_timer

# respawn logic
func respawn():
	visible = true
	dead = false
	can_respawn = false
	_health = max_health
	global_transform.origin = respawn_location
	$AnimationPlayer.play("respawn")
	
	# restore ammo
	_current_ammo = ammo_holds.duplicate()
	_total_ammo = start_total_ammo.duplicate()
	_update_ammo_labels()
	
	# update health label
	take_damage(0)

# delay time before respawn
func wait_for_respawn(delta):
	_death_timer_count -= delta
	$Head/Camera/DeathScreen/DeathUIElements/RespawnTimerNum.text = String(max(0, stepify(_death_timer_count, 0.1)))
	if _death_timer_count < 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		can_respawn = true
		$Head/Camera/DeathScreen/DeathUIElements/RespawnButton.disabled = false
	if can_respawn and $Head/Camera/DeathScreen/DeathUIElements/RespawnButton.pressed:
		respawn()

# pickup other items
func _on_Area_area_entered(area):
	if area.is_in_group("akammo"):
		_total_ammo[1] += 25
		_update_ammo_labels()
		area.get_parent().get_parent().queue_free()
