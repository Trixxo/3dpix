extends Spatial

var cube_projectile_scene = preload("res://Projectile/Projectile.tscn")
var experience_sentinel_scene = preload("res://Experience/ExperienceSentinel.tscn")
var target_velocity
var _timer
var attack_speed = GlobalVars.attack_speed
var origin_rotation
var origin_transform
var interpolation_factor = 0

signal finished_interpolation

func _ready():
    origin_transform = transform
    origin_rotation = transform.basis

    GlobalVars.connect('update', self, '_global_vars_updated')

    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "instance_cube")
    _timer.set_wait_time(1.0 / GlobalVars.attack_speed)
    _timer.set_one_shot(false)
    _timer.start()

func _process(dt):
    if target_velocity != null:
        transform.basis = Basis(interpolate_quat(target_velocity, dt).get_euler())

func _global_vars_updated():
    var existing_sentinels = get_tree().get_nodes_in_group("experience_sentinels").size()
    var sentinels_to_spawn = GlobalVars.experience_sentinels - existing_sentinels
    for i in range(sentinels_to_spawn):
        var experience_sentinel = experience_sentinel_scene.instance()
        experience_sentinel.transform.origin.y = 1
        get_tree().get_root().add_child(experience_sentinel)
        
    _timer.set_wait_time(1.0 / GlobalVars.attack_speed)

func instance_cube():
    var cube
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.size() > 0 and target_velocity == null:
        cube = cube_projectile_scene.instance()
        cube.transform.origin.y = 4
        cube.vel = GlobalVars.rand_vec_on_sphere() * cube.speed
        cube.transform = cube.transform.translated(cube.vel.normalized() * (self.mesh.mid_height / 2.0))

        target_velocity = cube.vel

        yield(self, 'finished_interpolation')
        get_tree().get_root().add_child(cube)
    
func interpolate_quat(target, dt):
    var origin_quat = Quat(origin_rotation)
    var target_transform = Transform.IDENTITY.looking_at(target, Vector3(0, 1, 0))
    # target_transform = target_transform.rotated(target_transform.basis.x, -PI / 2.0)
    var target_quat = Quat(target_transform.basis)

    if ((-transform.basis.z.normalized()).distance_to(target.normalized())) < 0.1:
        emit_signal('finished_interpolation')
        origin_rotation = transform.basis
        interpolation_factor = 0
        target_velocity = null
        return Quat(transform.basis)
    else:
        interpolation_factor += dt * GlobalVars.attack_speed * 1.5
        interpolation_factor = min(1, interpolation_factor)
        return origin_quat.normalized().slerp(target_quat.normalized(), interpolation_factor)
