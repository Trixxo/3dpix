extends Spatial

var hexagon_scene = preload("Hexagon.tscn")
var hex_highlight_scene = preload("Highlight.tscn")
var cube_scene = preload("res://Tower/PrismTower.tscn")

var cellsize = Vector2(2.3, 2.3)
var map_size = 1
var hex_map = hexes_in_range(map_size)
var intersection
var ground_bounds_top = []
var ground_bounds_bottom = []
var axial_pos

onready var view_size = get_viewport().size
onready var highlight = hex_highlight_scene.instance()

signal found_bounds

func _ready():
    create_hex_meshes_from_cells()
    get_tree().get_root().call_deferred('add_child', highlight)
    highlight.visible = false

func _process(_dt):
    pass

func _input(event):
    if event.is_action_pressed("game_select") and axial_pos in hex_map:
        var world_pos = intersection_to_world_axial()
        var cube = cube_scene.instance()
        cube.transform.origin = Vector3(world_pos.x, 2.25, world_pos.y)
        get_tree().get_root().add_child(cube)

func _physics_process(_dt):
    var camera = $'../Camera'

    var space_state = get_world().direct_space_state

    var mouse_position = get_viewport().get_mouse_position() / OS.window_size * get_viewport().size

    var ray_origin = camera.project_ray_origin(mouse_position)

    if ground_bounds_bottom.size() == 0:
        var coords = Vector2(view_size.x, 0)
        var ray_og = camera.project_ray_origin(coords)
        var intersection_top_right = space_state.intersect_ray(ray_og, ray_og + camera.project_ray_normal(coords) * 2000).position
        coords = Vector2(0, 0)
        ray_og = camera.project_ray_origin(coords)
        var intersection_top_left = space_state.intersect_ray(ray_og, ray_og + camera.project_ray_normal(coords) * 2000).position
        coords = Vector2(view_size.x, view_size.y)
        ray_og = camera.project_ray_origin(coords)
        var intersection_bottom_right = space_state.intersect_ray(ray_og, ray_og + camera.project_ray_normal(coords) * 2000).position
        coords = Vector2(0, view_size.y)
        ray_og = camera.project_ray_origin(coords)
        var intersection_bottom_left = space_state.intersect_ray(ray_og, ray_og + camera.project_ray_normal(coords) * 2000).position

        ground_bounds_top = [Vector2(intersection_top_left.x, intersection_top_left.z), Vector2(intersection_top_right.x, intersection_top_right.z)]
        ground_bounds_bottom = [Vector2(intersection_bottom_left.x, intersection_bottom_left.z), Vector2(intersection_bottom_right.x, intersection_bottom_right.z)]

        emit_signal("found_bounds")

    var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000

    intersection = space_state.intersect_ray(ray_origin, ray_end)

    if not intersection.empty():
        var world_pos = intersection_to_world_axial()

        axial_pos = pixel_to_pointy_hex(Vector2(intersection.position.x, intersection.position.z)) 
        
        if axial_pos in hex_map:
            highlight.transform.origin = Vector3(world_pos.x, 2, world_pos.y)
            highlight.show()

func intersection_to_world_axial():
        var pos = Vector2(intersection.position.x, intersection.position.z)

        var axial_pos = pixel_to_pointy_hex(pos) 
        var pixel_pos = cell_to_pixel(axial_pos) 

        return pixel_pos

func pixel_to_pointy_hex(point):
    var q = (sqrt(3.0)/3.0 * point.x  -  1.0/3.0 * point.y) / cellsize.x
    var r = (                        2.0/3.0 * point.y) / cellsize.y
    return axial_round(Vector2(q, r))

func cube_round(frac):
    var q = round(frac.x)
    var r = round(frac.y)
    var s = round(frac.z)

    var q_diff = abs(q - frac.x)
    var r_diff = abs(r - frac.y)
    var s_diff = abs(s - frac.z)

    if q_diff > r_diff and q_diff > s_diff:
        q = -r-s
    elif r_diff > s_diff:
        r = -q-s
    else:
        s = -q-r

    return Vector3(q, r, s)

func axial_round(hex):
    return cube_to_axial(cube_round(axial_to_cube(hex)))

func cell_to_pixel(cell : Vector2) -> Vector2:
    var x = (sqrt(3.0) * cell.x + sqrt(3.0) / 2.0 * cell.y) * cellsize.x
    var y = (0.0 * cell.x + 3.0 / 2.0 * cell.y) * cellsize.y
    return Vector2(x, y)

func hexes_in_range(N : int) -> Array:
    var results = []
    for q in range(-N, N + 1):
        for r in range(-N, N + 1):
            for s in range(-N, N + 1):
                if q + r + s == 0:
                    results.append(Vector2(q, r))
    return results
# Called when the node enters the scene tree for the first time.
func create_hex_meshes_from_cells():
    for hex in hex_map:
        var pixe_pos = cell_to_pixel(hex)
        var freshgon = hexagon_scene.instance()
        get_tree().get_root().call_deferred("add_child", freshgon)
        freshgon.transform.origin = Vector3(pixe_pos.x, 0, pixe_pos.y)

func axial_to_cube(hex):
    var q = hex.x
    var r = hex.y
    var s = -q-r
    return Vector3(q, r, s)

func cube_to_axial(cube):
    var q = cube.x
    var r = cube.y
    return Vector2(q, r)


static func delete_children(node):
    for n in node.get_children():
        if n.name != 'ProjectionCamera':
            node.remove_child(n)
            n.queue_free()
