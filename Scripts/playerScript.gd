extends CharacterBody3D

const SPEED = 5.0 
const JUMP_VELOCITY = 4.5
const SPRINT_MULTIPLIER = 2.0
const SENSITIVITY = 0.001

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

@onready var floorMesh := $".."/Bakke

var matGreen = preload("res://Matirials/green.tres")
var matRed = preload("res://Matirials/red.tres")



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * delta
		floorMesh.set_surface_override_material(0,matRed)
	else:
		floorMesh.set_surface_override_material(0,matGreen)
		
	
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	

	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction.x * SPEED * SPRINT_MULTIPLIER
			velocity.z = direction.z * SPEED * SPRINT_MULTIPLIER
		else:
			velocity.x = direction.x * SPEED 
			velocity.z = direction.z * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

