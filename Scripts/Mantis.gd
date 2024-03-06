extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	play("Armature|Swim")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if is_playing():
		pass
	else:
		play("Armature|Swim")

