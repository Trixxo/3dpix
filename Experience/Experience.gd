extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var elapsed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    elapsed += dt
    transform = transform.translated(Vector3(0, sin(elapsed * 3.0) * 0.02, 0))
