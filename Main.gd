extends Spatial

var experience_sentinel_scene = preload("res://Experience/ExperienceSentinel.tscn")

func _ready():
    var _e = GlobalVars.connect('update', self, '_global_vars_updated')

func _global_vars_updated():
    var existing_sentinels = get_tree().get_nodes_in_group("experience_sentinels").size()
    var sentinels_to_spawn = GlobalVars.experience_sentinels - existing_sentinels
    for _i in range(sentinels_to_spawn):
        var experience_sentinel = experience_sentinel_scene.instance()
        experience_sentinel.transform.origin.y = 1
        get_tree().get_root().add_child(experience_sentinel)
        

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_SPACE:
            var hex_map_node = $HexGrid
            hex_map_node.delete_children(hex_map_node)
            hex_map_node.map_size += 1			
            hex_map_node.hex_map = hex_map_node.hexes_in_range(hex_map_node.map_size)
            hex_map_node.create_hex_meshes_from_cells()
