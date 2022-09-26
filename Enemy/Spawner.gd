extends Spatial

var normal_enemy_scene = preload("res://Enemy/Enemy.tscn")
var chonk_enemy_scene = preload("res://Enemy/EnemyChonk.tscn")
var spawn_amount = 1.0
var boss_wave_chance = 0.1
var bounds_top
var bounds_bottom
var _timer

onready var view_size = get_viewport().size

func _ready():
    find_bounds()

    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "check_next_wave")
    _timer.set_wait_time(1.0)
    _timer.set_one_shot(true)
    check_next_wave()

# If there are no enemies left, spawn a new wave.
func check_next_wave():
    # check if it's time for a new wave already
    if get_tree().get_nodes_in_group("enemies").size() > 0: 
        # it's not time yet, check again later
        _timer.start()
        return
    # wait at least a few seconds between waves to give the player some time to breathe
    yield(get_tree().create_timer(3.0), "timeout")

    var is_boss_wave = randf() < boss_wave_chance
    # var is_normal_spawn = randf() < 0.5

    for _i in range(round(spawn_amount)):
        var is_chonk_spawn = randf() < 0.5
        var enemy
        if is_chonk_spawn:
            enemy = chonk_enemy_scene.instance()
        else:
            enemy = normal_enemy_scene.instance()
        if is_boss_wave: 
            enemy.health *= 2
            enemy.effective_health *= 2
            enemy.base_scale *= 2
        var pos = rand_point_on_bounds()
        add_child(enemy)
        enemy.global_transform[3] = Vector3(pos.x, 4, pos.y)

    spawn_amount += 4.0
    # start checking for the next wave
    _timer.start()

func find_bounds():
    var camera = $"../Camera"
    var space_state = get_world().direct_space_state

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

    bounds_top = [Vector2(intersection_top_left.x, intersection_top_left.z), Vector2(intersection_top_right.x, intersection_top_right.z)]
    bounds_bottom = [Vector2(intersection_bottom_left.x, intersection_bottom_left.z), Vector2(intersection_bottom_right.x, intersection_bottom_right.z)]

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
