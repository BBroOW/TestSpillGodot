extends CharacterBody3D

const SPEED = 5.0 
const JUMP_VELOCITY = 4.5
const SPRINT_MULTIPLIER = 2.0
const SENSITIVITY = 0.001
@export var ShootPoint: Node3D
@export var BulletSpeed: float
@export var BulletGravity: float
@export var BulletDamage: float



const BULLET = preload("res://Assets/Bullet.tscn")

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var rootNode = $".."

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

@onready var floorMesh := $".."/Bakke
@onready var deathZone := $".."/DeathZone

@onready var nextLevel2 := $".."/Level1/Finish1/Sketchfab_Scene/Sketchfab_model/Root/Mountain/Door/NextLevel2

@onready var jumpSoundEffect := $Jump


#Level 3 cords
#transform.origin = Vector3(0, 5, -600)

var matGreen = preload("res://Matirials/green.tres")
var matRed = preload("res://Matirials/red.tres")


#Movement

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		SpawnBullet()
		
func SpawnBullet():
		var clonebullet = BULLET.instantiate()
		rootNode.add_child(clonebullet)
		clonebullet.global_transform.origin = ShootPoint.global_transform.origin
		clonebullet.global_transform.basis = ShootPoint.global_transform.basis
		clonebullet.scale = Vector3(1, 1, 1)
		clonebullet.Initialize(ShootPoint.global_transform, BulletSpeed, BulletGravity, BulletDamage)
			

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

		
	
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumpSoundEffect.play()


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

#Death

func _on_death_zone_body_shape_entered(body_rid:RID, body:Node3D, body_shape_index:int, local_shape_index:int):
	transform.origin = Vector3(0, 1, 0)

#Next Level2

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/WorldCave.tscn")
	else:
		pass
