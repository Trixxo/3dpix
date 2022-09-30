extends Spatial

onready var init_pos = global_transform[3]

export var max_speed := 40.0
var speed_factor := 0.6
var minimum_speed := 0.9 * max_speed
var speed := max_speed * speed_factor

var vel := Vector3.ZERO
var acc := Vector3.ZERO
var max_steer_force := 50
var steer_force := 0.2

var damage = GlobalVars.projectile_damage
var knockback_force = GlobalVars.knockback_force
var stun_duration = 0.0

var target = null setget set_target

var enemy_scene = preload("res://Enemy/Enemy.tscn")
var sphere_expolsion_scene = preload("ParticleDamage.tscn")
var experience_scene = preload("res://Experience/Experience.tscn")

func _process(dt):
    steer_force = pow(speed_factor, 2) * max_steer_force
    speed = update_speed()
    acc += seek()
    vel += acc * dt
    vel = GlobalVars.clamp(vel, speed)
    # rotation = vel
    # look_at(Vector3(1, 0, 0), Vector3.UP)
    # rotation.y = PI / 2.0
    transform.basis = Transform.IDENTITY.looking_at(vel, Vector3.UP).basis
        
    if is_instance_valid(target):
        var distance_to_target = global_transform[3].distance_to(target.global_transform[3])
        # dont move further than the required distance to the target
        var step = min(distance_to_target - 1, vel.length() * dt)

        global_transform = global_transform.translated(Vector3.FORWARD * step)

        if ( distance_to_target <= 2):
            hit_target()
    else:
        find_target()

func hit_target():
    target.hit(self, Towers.ColorGroup.Purple, damage, knockback_force, stun_duration)

    queue_free()

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()

func find_target():
    var enemies = get_tree().get_nodes_in_group("enemies")
    var enemies_sorted = ArrayExtra.filter_by_method(enemies, "can_attack")
    enemies_sorted.sort_custom(SortMan, "enemy_sort_dist")
    if not enemies_sorted.size() > 0: return
    var first_enemy = enemies_sorted[0]
    self.target = first_enemy

func set_target(val):
    target = val
    target.effective_health -= damage

func seek() -> Vector3:
    var steer = Vector3.ZERO
    if is_instance_valid(target):
        var desired = (target.global_transform.origin - global_transform.origin).normalized() * speed
        steer = (desired - vel).normalized() * steer_force
    return steer

func update_speed() -> float:
    if is_instance_valid(target) and global_transform[3].length() < self.current_max_distance(target.global_transform[3]):
        speed_factor = global_transform[3].length() / self.current_max_distance(target.global_transform[3])

    return min(minimum_speed + speed_factor * max_speed, max_speed)

func current_max_distance(target_position: Vector3) -> float:
    return (target_position - init_pos).length()
