extends MeshInstance

var idle_movement_factor = 0 + randf() * PI
onready var camera = $'../../Camera'
onready var initial_scale = scale

func _process(dt):
    idle_movement_factor += dt / 2
    transform = transform.translated(Vector3(dt * 0.5 * sin(3 * sin(idle_movement_factor)), dt * 0.2 * sin(0.3 + idle_movement_factor * 0.5), 0))
    rotate_object_local(Vector3.FORWARD, dt * 0.02 * sin(0.2 + idle_movement_factor))

    var space_state = get_world().direct_space_state

    var mouse_position = get_viewport().get_mouse_position() / OS.window_size * get_viewport().size

    var ray_origin = camera.project_ray_origin(mouse_position)
    var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000

    # use collision layer 2 to detect only cards
    var intersection = space_state.intersect_ray(ray_origin, ray_end, [], 0x2, false, true)
    var should_be_hovering = not intersection.empty() and intersection.collider == $Area
    if should_be_hovering:
        scale = initial_scale * 1.05
    else:
        # user hovered before, but stopped hovering now, we need to undo the scale
        scale = initial_scale
