extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
    yield(get_tree().create_timer(4.0), "timeout")
    queue_free()
    
func set_emitting(val):
    $Particles.emitting = val
    $Particles2.emitting = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
