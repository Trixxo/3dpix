extends Spatial


var cube_projectile_scene = preload("res://Tower/PurpleTower/GreenMainProjectile/Projectile.tscn")
var experience_sentinel_scene = preload("res://Experience/ExperienceSentinel.tscn")
var _timer
var attack_speed = GlobalVars.attack_speed
var origin_rotation
var origin_transform
var interpolation_factor = 0
var height_offset = 0
var projectiles := 0
var elapsed := 0.0

func _ready():
    add_to_group("main_towers")

    var main_towers_amount = get_tree().get_nodes_in_group("main_towers").size()

    transform.origin.y += main_towers_amount * 4
    height_offset = transform.origin.y

    origin_transform = transform
    origin_rotation = transform.basis

    var _e = GlobalVars.connect('tower_built', self, '_global_vars_updated')

    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "instance_cube")
    _timer.set_wait_time(0.02)
    _timer.set_one_shot(false)
    _timer.start()

func _process(dt):
    elapsed += dt
    transform.basis = Basis().rotated(Vector3.UP, sin(elapsed) * PI / 2.0).rotated(Vector3.UP, PI)

func _global_vars_updated(all_types, _new_type):
    var bonus_attack_speed := 0.0
    var purple_towers := 0

    for type in all_types:
        match Towers.color_for_tower(type):
            Towers.ColorGroup.Purple:
                purple_towers += 1
    
    _timer.set_wait_time(1.0 / ((GlobalVars.attack_speed * 10.0) + bonus_attack_speed))

func idle_movement(dt):
    rotation.y += 0.3 * dt
    rotation.x += 0.3 * dt
                
func instance_cube():
    var cube
    var all_enemies = get_tree().get_nodes_in_group("enemies")
    var enemies = ArrayExtra.filter_by_method(all_enemies, "can_attack")
    if enemies.size() > 0:
        cube = cube_projectile_scene.instance()
        cube.target_dir = -transform.basis.z
        cube.transform = cube.transform.translated(cube.target_dir.normalized() * .5)
        cube.transform.origin.y = height_offset

        get_tree().get_root().add_child(cube)
