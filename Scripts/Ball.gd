
extends Node3D

var speed: float #Hastigheten av kulen
var gravity: float #TyngdeKraften for kulen. denne bestemmer hvor mye kulen går nedover
var startPosition: Vector3 #Startposisjonen til kulen
var StartForward: Vector3 #Startretningen til kulen
var is_initialized: bool = false #Sjekker om kulen er initialisert
var StartTime: float = -1 #Tiden kulen ble initialisert
var Damage: float = 100 #Skaden kulen gjør #Prefab for blodet som vises når kulen treffer fienden
@onready var root = $".." #Roten til verden

#Denne functionen initialiserer kulen med variabler sendt fra våpenet
func Initialize(StartPoint: Transform3D, StartSpeed: float, StartGravity: float, DamageStart: float):
	startPosition = StartPoint.origin
	StartForward = -StartPoint.basis.z.normalized()
	print(StartForward, startPosition)
	speed = StartSpeed
	gravity = StartGravity
	Damage = DamageStart
	is_initialized = true
# Denne funksjonen finner punktet på kulen basert på tiden
func FindPointOnBullet(time: float) -> Vector3:
	var point: Vector3 = startPosition + (StartForward * speed * time)
	var gravityVec: Vector3 = Vector3.DOWN * gravity * time * time
	return point + gravityVec
# Denne funksjonen kaster en ray mellom to punkter for å sjekke om det er en kollisjon
func CastRayBetweenPoints(start: Vector3, end: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = start
	var endpoint = end
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func _physics_process(delta):
	if !is_initialized: return

	if StartTime < 0:
		StartTime = Time.get_ticks_msec() / 1000.0

	var current_time = Time.get_ticks_msec() / 1000.0 - StartTime
	var nextTime = current_time + delta

	var CurrentPoint: Vector3 = FindPointOnBullet(current_time)
	var NextPoint: Vector3 = FindPointOnBullet(nextTime)

	if CastRayBetweenPoints(CurrentPoint, NextPoint):
		queue_free()
	# Hvis kulen treffer noe som har TakeDamage funksjonen, så kaller den funksjonen og lager blod. husk og lag en enemy som du kan treffe
	var space_state = get_world_3d().direct_space_state
	var origin = CurrentPoint
	var endpoint = NextPoint
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var result = space_state.intersect_ray(query)
	if result.size() > 0:
		var collider = result["collider"]
		if collider != null:
			var script_instance = find_enemy_script(collider)
			if script_instance != null and script_instance.has_method("TakeDamage"):
				#body.apply_impulse(Vector3.UP * 10, Vector3.ZERO)
				script_instance.TakeDamage(Damage)
				queue_free()
		else:
			print(collider.name)
			queue_free()
# Denne funksjonen finner scriptet til fienden
func find_enemy_script(node):
	# Traverse the node hierarchy to find the script instance in the enemy node
	while node != null:
		if node.has_method("TakeDamage"):
			return node
		node = node.get_parent()

	return null
func _process(delta):
	if !is_initialized || StartTime < 0: return

	var current_time = Time.get_ticks_msec() / 1000.0 - StartTime
	var current_point: Vector3 = FindPointOnBullet(current_time)
	transform.origin = current_point

# Denne funksjonen blir kalt når kulen har eksistert i 5 sekunder
func _on_timer_timeout():
	print("Destroyd bullet")
	queue_free()
