extends Spatial

var cube_projectile_scene = preload("../Tower/BlueTower/BlueMainProjectile/Projectile.tscn")
var _timer
var origin_rotation
var origin_transform
var interpolation_factor = 0
var height_offset = 0
var original_scale

var bonus_damage := 0.0
var bonus_knockback := 0.0
var bonus_attack_speed := 0.0

func _ready():
    add_to_group("main_towers")
    var main_towers_amount = get_tree().get_nodes_in_group("main_towers").size()
    transform.origin.y += main_towers_amount * 4
    height_offset = transform.origin.y
    origin_transform = transform
    origin_rotation = transform.basis
    original_scale = scale

    instance_cube()

    var _e = GlobalVars.connect('update', self, '_global_vars_updated')

func _process(dt):
    scale = original_scale

func _global_vars_updated(all_types, _new_type):
    bonus_attack_speed = 0.0
    bonus_knockback = 0.0
    bonus_damage = 0.0
    for type in all_types:
        match Towers.color_for_tower(type):
            Towers.ColorGroup.Red:
                bonus_attack_speed += 0.3
        
        match type:
            Towers.Type.Cylinder:
                bonus_attack_speed += 1.0
            Towers.Type.Cube:
                bonus_knockback += 1.0

    _timer.set_wait_time(1.0 / (GlobalVars.attack_speed + bonus_attack_speed))

func instance_cube():
    # var all_enemies = get_tree().get_nodes_in_group("enemies")
    # var enemies = ArrayExtra.filter_by_method(all_enemies, "can_attack")
    # if enemies.size() > 0:
    var cube = cube_projectile_scene.instance()
    cube.damage = GlobalVars.projectile_damage / 2 + bonus_damage
    cube.knockback_force = GlobalVars.knockback_force + bonus_knockback
    cube.transform.origin.y = height_offset
    get_tree().get_root().add_child(cube)
