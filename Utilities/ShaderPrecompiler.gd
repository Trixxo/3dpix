extends Spatial

const scenes_to_compile = [
    preload("res://UI/Card.tscn"),
    preload("res://Experience/Experience.tscn")
]

# A hack for compiling some shaders at the start of the game. 
# Without it, there are slight lags when a new material
# is first seen.
func _ready():
    for type in Towers.Type.values():
        var scene = Towers.scene_for_tower(type)
        var preview_node = scene.instance()
        add_child(preview_node)
    
    for scene in scenes_to_compile:
        var node = scene.instance()
        node.set_script(null)
        add_child(node)

    # one frame is not enough to pre-compile shaders,
    # but two frames seem to work
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    queue_free()
