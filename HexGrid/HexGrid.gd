extends MultiMeshInstance

var hexagon_scene = preload("Hexagon.tscn")

const base_tower_offset = 2.25
const tower_offset = 1.5

var cellsize = Vector2(2.3, 2.3)
var map_size = 1
# Array of Vector2s containing hex positions
var hex_map := hexes_in_range(map_size)
var ground_bounds_top = []
var ground_bounds_bottom = []
var building_preview: MeshInstance
var new_tower_type

func _ready():
    create_hex_meshes_from_cells()

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
    multimesh.instance_count = hex_map.size()
    for i in range(hex_map.size()):
        var hex = hex_map[i]
        var pixe_pos = cell_to_pixel(hex)
        var freshgon = hexagon_scene.instance()
        freshgon.transform.origin = Vector3(pixe_pos.x, 0, pixe_pos.y)
        multimesh.set_instance_transform(i, Transform(Basis().scaled(Vector3.ONE * 2), Vector3(pixe_pos.x, 0, pixe_pos.y)))
        freshgon.connect("mouse_entered", self, "_mouse_entered_hexagon", [freshgon])
        freshgon.connect("mouse_exited", self, "_mouse_exited_hexagon")
        freshgon.connect("input_event", self, "_mouse_clicked_hexagon", [freshgon])
        add_child(freshgon)

func _mouse_entered_hexagon(gon):
    if not is_instance_valid(building_preview): return

    building_preview.transform.origin = gon.global_transform.origin \
        + Vector3.UP * new_tower_height(gon.tower_types)
    building_preview.show()

func _mouse_exited_hexagon():
    if not is_instance_valid(building_preview): return

    building_preview.hide()

func _mouse_clicked_hexagon(_cam, event, _click_pos, _click_normal, _shape_idx, gon):
    if (not event.is_action_pressed("game_select") 
            or not is_instance_valid(building_preview) 
            or new_tower_type == null):
        return 

    if (new_tower_type == Towers.Type.Cube):
        building_preview.add_to_group("main_towers")
        var main_towers_amount = get_tree().get_nodes_in_group("main_towers").size()

        building_preview.transform.origin = Vector3(0, 4 * main_towers_amount, 0)
    else:
        building_preview.transform.origin = Vector3(gon.transform.origin.x, new_tower_height(gon.tower_types), gon.transform.origin.z)

    gon.tower_types.append(new_tower_type)

    Towers.apply_tower_effect(new_tower_type)

    # reset state for selecting hexagon to build
    building_preview = null
    new_tower_type = null

func new_tower_height(existing_towers: Array) -> float:
    return base_tower_offset + tower_offset * existing_towers.size()

func start_building_tower(preview_node: MeshInstance, tower_type):
    building_preview = preview_node.duplicate()
    building_preview.scale = Vector3.ONE
    building_preview.rotation_degrees = Vector3.ZERO
    building_preview.cast_shadow = SHADOW_CASTING_SETTING_ON
    building_preview.hide()
    add_child(building_preview)
    new_tower_type = tower_type


static func delete_children(node):
    for n in node.get_children():
        if n.name != 'ProjectionCamera':
            node.remove_child(n)
            n.queue_free()
