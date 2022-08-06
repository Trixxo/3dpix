extends Spatial

var cube_projectile_scene = preload("res://Projectile/Projectile.tscn")
var target_velocity
var _timer
var origin_rotation
var origin_transform
var interpolation_factor = 0
var height_offset = 0
var original_scale

var bonus_damage := 0.0
var bonus_knockback := 0.0
var bonus_attack_speed := 0.0
var bonus_stun_duration := 0.0

signal finished_interpolation

func _ready():
    add_to_group("main_towers")
    var main_towers_amount = get_tree().get_nodes_in_group("main_towers").size()
    transform.origin.y += main_towers_amount * 4
    height_offset = transform.origin.y
    origin_transform = transform
    origin_rotation = transform.basis
    original_scale = scale

    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "instance_cube")
    _timer.set_wait_time(1.0 / GlobalVars.attack_speed)
    _timer.set_one_shot(false)
    _timer.start()

    var _e = GlobalVars.connect('tower_built', self, '_global_vars_updated')

func _process(dt):
    if target_velocity != null:
        transform.basis = Basis(interpolate_quat(target_velocity, dt).get_euler())
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
            Towers.Type.Prism:
                bonus_stun_duration += 0.5

    _timer.set_wait_time(1.0 / (GlobalVars.attack_speed + bonus_attack_speed))

func instance_cube():
    var all_enemies = get_tree().get_nodes_in_group("enemies")
    var enemies = ArrayExtra.filter_by_method(all_enemies, "can_attack")
    if enemies.size() > 0 and target_velocity == null:
        var target_enemy = enemies[randi() % enemies.size()]
        var target_dir = (target_enemy.global_transform.origin - global_transform.origin).normalized()

        var cube = cube_projectile_scene.instance()
        cube.max_speed = 150.0
        cube.damage = GlobalVars.projectile_damage / 2 + bonus_damage
        cube.knockback_force = GlobalVars.knockback_force + bonus_knockback
        cube.stun_duration = bonus_stun_duration
        cube.target = target_enemy
        cube.vel = target_dir * cube.speed
        cube.transform.origin.y = height_offset

        target_velocity = cube.vel

        yield(self, 'finished_interpolation')
        get_tree().get_root().add_child(cube)
    
func interpolate_quat(target, dt):
    # if target is the origin, `looking_at` will crash.
    # there's no reasonable way to handle this, so just return.
    if target == Vector3.ZERO: return

    var origin_quat = Quat(origin_rotation.orthonormalized())
    var target_transform = Transform.IDENTITY.looking_at(target, Vector3.UP)
    var target_quat = Quat(target_transform.basis)

    if ((-transform.basis.z.normalized()).distance_to(target.normalized())) < 0.1:
        emit_signal('finished_interpolation')
        origin_rotation = transform.basis
        interpolation_factor = 0
        target_velocity = null
        return Quat(transform.basis.orthonormalized())
    else:
        interpolation_factor += dt * GlobalVars.attack_speed * 4.5
        interpolation_factor = min(1, interpolation_factor)
        return origin_quat.normalized().slerp(target_quat.normalized(), interpolation_factor)
