extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var passed


# Called when the node enters the scene tree for the first time.
func _ready():
	passed = 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	passed += 0.2 * delta
#	transform = transform.translated(Vector3(cos(passed), 0, sin(passed)))
