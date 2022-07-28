extends Spatial

var enemy_scene = preload("res://Enemy/Enemy.tscn")
var spawn_amount = 1.0
var bounds_top
var bounds_bottom
var _timer

func _ready():
    var hex_grid = get_node("../hex_map")
    yield(hex_grid, "found_bounds")
    bounds_top = hex_grid.ground_bounds_top
    bounds_bottom = hex_grid.ground_bounds_bottom

    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "instance_enemy")
    _timer.set_wait_time(7.0)
    _timer.set_one_shot(false)
    _timer.start()
    instance_enemy()

func instance_enemy():
    for _i in range(round(spawn_amount)):
        var enemy = enemy_scene.instance()
        var pos = rand_point_on_bounds()
        # get_tree().get_root().get_node("Node2D/Viewport").add_child(enemy)
        add_child(enemy)
        enemy.global_transform[3] = Vector3(pos.x, 4, pos.y)

    spawn_amount += 0.1

func rand_point_on_bounds():

    var point = Vector2()

    var rand_hor = rand_range(bounds_top[0].x, bounds_top[1].x)
    var rand_vert = rand_range(bounds_top[0].y, bounds_bottom[0].y)
    var vert_sides = [bounds_top[0].y, bounds_bottom[0].y]

    var which_dir = randi() % 2
    var which_side = randi() % 2

    if (which_dir == 0):
        point.x = rand_hor
        point.y = sign(vert_sides[which_side]) * (abs(vert_sides[which_side]) + 1)
    else:
        point.y = rand_vert
        point.x = sign(bounds_top[which_side].x) * (abs(bounds_top[which_side].x) + 1)

    return point
