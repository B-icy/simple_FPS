extends MeshInstance

onready var dummy_cam = $DummyCam
onready var mirror_cam = $Viewport/Camera

func _ready():
	add_to_group("mirrors")
	$Viewport.size = Vector2(1920, 1080)

func update_cam(main_cam_transform):
	scale.z *= -1
	dummy_cam.global_transform = main_cam_transform
	scale.z *= -1
	mirror_cam.global_transform = dummy_cam.global_transform
	mirror_cam.global_transform.basis.x *= -1
