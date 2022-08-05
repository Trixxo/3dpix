extends MultiMeshInstance

var hexagon_scene = preload("Hexagon.tscn")

const base_tower_offset = 2.25
const tower_offset = 1.5

# all relative positions that are directly adjacent to a given hexagon.
const neighbor_positions = [
    Vector2(1, 0), Vector2(1, -1), Vector2(0, -1),
    Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

var cellsize = Vector2(2.3, 2.3)
var map_size = 1
# Array of Vector2s containing hex positions in axial coordinates
var hex_map := hexes_in_range(map_size)
var ground_bounds_top = []
var ground_bounds_bottom = []
var building_preview: MeshInstance
var new_tower_type

func _ready():
    multimesh.instance_count = 200
    multimesh.visible_instance_count = 0
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
                # q + r + s == 0: is part of the cube hexagonal grid
                # q != 0 and r != 0 and s != 0: is not the tile in the absolute center
                if (q + r + s == 0) and (q != 0 or r != 0 or s != 0):
                    results.append(Vector2(q, r))
    return results

func create_hex_meshes_from_cells():
    for i in range(hex_map.size()):
        var hex = hex_map[i]
        var freshgon = create_hexagon(hex)
        unlock_hexagon(freshgon)
    
    # use a duplicate of hex_map here because we're extending hex_map while 
    # looping over it which would create an infinite loop
    for position in hex_map.duplicate():
        create_click_detection_hexagons(position)


# For each slot around the given position in which no hexagon exists,
# create a locked hexagon for detecting clicks.
# position is in axial coordinates.
func create_click_detection_hexagons(origin: Vector2):
    for neighbor_distance in neighbor_positions:
        var neighbor_position = origin + neighbor_distance
        # if hexagon already exists, do nothing for this position
        if neighbor_position in hex_map: continue
        
        # create a locked hexagon for this position
        hex_map.append(neighbor_position)
        var _freshgon = create_hexagon(neighbor_position)

func create_hexagon(axial_position: Vector2) -> Area:
    var pixe_pos = cell_to_pixel(axial_position)
    var freshgon = hexagon_scene.instance()
    freshgon.axial_position = axial_position
    freshgon.transform.origin = Vector3(pixe_pos.x, 0, pixe_pos.y)
    freshgon.connect("mouse_entered", self, "_mouse_entered_hexagon", [freshgon])
    freshgon.connect("mouse_exited", self, "_mouse_exited_hexagon")
    freshgon.connect("input_event", self, "_mouse_clicked_hexagon", [freshgon])
    add_child(freshgon)
    return freshgon

# make the given hexagon visible.
func unlock_hexagon(gon):
    if not gon.is_locked: return 

    multimesh.visible_instance_count += 1
    var transform = Transform(Basis().scaled(Vector3.ONE * 2), gon.transform.origin)
    multimesh.set_instance_transform(multimesh.visible_instance_count - 1, transform)
    gon.is_locked = false
    create_click_detection_hexagons(gon.axial_position)

func _mouse_entered_hexagon(gon):
    if (not is_instance_valid(building_preview)
            or gon.is_locked
            or not Towers.can_build_type(new_tower_type, gon.tower_types)): 
        return

    building_preview.transform.origin = gon.global_transform.origin \
        + Vector3.UP * new_tower_height(gon.tower_types)
    building_preview.show()

func _mouse_exited_hexagon():
    if not is_instance_valid(building_preview): return

    building_preview.hide()

func _mouse_clicked_hexagon(_cam, event, _click_pos, _click_normal, _shape_idx, gon):
    # if this wasn't a mouse click, do nothing
    if not event.is_action_pressed("game_select"):
        return

    # if we're not building anything at the moment, try to unlock the hexagon
    if (not is_instance_valid(building_preview) 
            or new_tower_type == null):

        if gon.is_locked:
            unlock_hexagon(gon)

        return 

    # if we're selecting a spot to build but are not allowed to build here,
    # do nothing
    if not Towers.can_build_type(new_tower_type, gon.tower_types):
        return

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
