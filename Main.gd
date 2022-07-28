extends ViewportContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_SPACE:
            var hex_map_node = $'Viewport/HexGrid'
            hex_map_node.delete_children(hex_map_node)
            hex_map_node.map_size += 1			
            hex_map_node.hex_map = hex_map_node.hexes_in_range(hex_map_node.map_size)
            hex_map_node.create_hex_meshes_from_cells()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
