extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var elapsed = 0
var picked_up
var _timer
var particle_vanish_scene = preload("ParticleVanish.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    add_to_group("experience_orbs")
    _timer = Timer.new()
    add_child(_timer)
    
    _timer.connect("timeout", self, "vanish")
    _timer.set_wait_time(0.5)
    _timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    elapsed += dt
    transform = transform.translated(Vector3(0, sin(elapsed * 3.0) * 0.02, 0))

func vanish():
    if (!picked_up):
        # yield(get_tree().create_timer(4.0), "timeout")
        var particle_vanish = particle_vanish_scene.instance()
        particle_vanish.set_emitting(true)
        particle_vanish.transform.origin = global_transform.origin
        get_tree().get_root().add_child(particle_vanish)
        queue_free()
