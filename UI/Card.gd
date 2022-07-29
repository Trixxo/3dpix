extends MeshInstance

var idle_movement_factor = 0 + randf() * PI
onready var camera = $'../../Camera'
onready var initial_scale = scale

func _ready():
    var _e = $Area.connect("mouse_entered", self, "_mouse_entered")
    var _e2 = $Area.connect("mouse_exited", self, "_mouse_exited")

func _process(dt):
    idle_movement_factor += dt / 2
    transform = transform.translated(Vector3(dt * 0.5 * sin(3 * sin(idle_movement_factor)), dt * 0.2 * sin(0.3 + idle_movement_factor * 0.5), 0))
    rotate_object_local(Vector3.FORWARD, dt * 0.02 * sin(0.2 + idle_movement_factor))

    $Preview.rotate(Vector3.UP, dt)

func _mouse_entered():
    scale = initial_scale * 1.05

func _mouse_exited():
    scale = initial_scale
