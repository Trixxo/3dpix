extends Area

var tower_types := []
var axial_position: Vector2
# This class is used for raycasting on clicks around existing hexagons.
# A "locked" hexagon is not visible and not shown in the game 
# but only exists to see on which position players want to build a new hexagon. 
var is_locked = true setget set_is_locked

func set_is_locked(val):
    is_locked = val
    # only hexagons that exist from the perspective of the player are added
    # to this group.
    add_to_group("hexagons")
