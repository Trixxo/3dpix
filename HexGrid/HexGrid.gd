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

func _physics_process(_dt):
    var camera = $'../Camera'

    var space_state = get_world().direct_space_state

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
        freshgon.transform.origin = Vector3(pixe_pos.x, 0, pixe_pos.y)
        add_child(freshgon)
        freshgon.get_node("Area").connect("mouse_entered", self, "_mouse_entered_hexagon", [freshgon])
        freshgon.get_node("Area").connect("mouse_exited", self, "_mouse_exited_hexagon")
        freshgon.get_node("Area").connect("input_event", self, "_mouse_clicked_hexagon", [freshgon])

func _mouse_entered_hexagon(gon):
    highlight.transform.origin = gon.global_transform.origin + Vector3.UP * 2
    highlight.show()

func _mouse_exited_hexagon():
    highlight.hide()

func _mouse_clicked_hexagon(_cam, event, _click_pos, _click_normal, _shape_idx, gon):
    if event.is_action_pressed("game_select"):
        var cube = cube_scene.instance()
        cube.transform.origin = Vector3(gon.transform.origin.x, 2.25, gon.transform.origin.z)
        get_tree().get_root().add_child(cube)


static func delete_children(node):
    for n in node.get_children():
        if n.name != 'ProjectionCamera':
            node.remove_child(n)
            n.queue_free()
