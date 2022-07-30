extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var idle = false
var elapsed = 0
var rand_dist
var dir


# Called when the node enters the scene tree for the first time.
func _ready():
    dir = transform.origin.normalized()
    rand_dist = randi() % 2 + 6
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    # elapsed += dt
    if idle and transform.origin.length() < rand_dist:
        transform.origin += dir * dt * 8.0
    elif transform.origin.length() > 2.0:
        transform.origin -= dir * dt * 8.0
    # global_rotation.y += dt8
