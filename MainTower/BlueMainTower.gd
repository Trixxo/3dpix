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

var blue_tower_amount := 0
var projectiles := []
var bounce_count := 0

func _ready():
    add_to_group("main_towers")
    var main_towers_amount = get_tree().get_nodes_in_group("main_towers").size()
    transform.origin.y += main_towers_amount * 4
    height_offset = transform.origin.y
    origin_transform = transform
    origin_rotation = transform.basis
    original_scale = scale

    var _e = GlobalVars.connect('tower_built', self, '_global_vars_updated')

func _process(_dt):
    scale = original_scale

func _global_vars_updated(all_types, new_type):
    blue_tower_amount = 0
    for type in all_types:
        match Towers.color_for_tower(type):
            Towers.ColorGroup.Blue:
                blue_tower_amount += 1

    if Towers.color_for_tower(new_type) == Towers.ColorGroup.Blue:
        instance_projectile()

    if new_type == Towers.Type.Lightning:
        self.bounce_count = 4
        for projectile in projectiles:
            projectile.bounce_count = self.bounce_count

func update_projectile_position():
    for i in range(projectiles.size()):
        projectiles[i].update_position(i + 1)

func instance_projectile():
    var projectile = cube_projectile_scene.instance()
    projectile.damage = GlobalVars.projectile_damage / 2 + bonus_damage
    projectile.knockback_force = GlobalVars.knockback_force + bonus_knockback
    projectile.transform.origin.y = GlobalVars.enemy_flight_height
    projectile.bounce_count = self.bounce_count
    projectiles.append(projectile)

    get_tree().get_root().add_child(projectile)

    update_projectile_position()
