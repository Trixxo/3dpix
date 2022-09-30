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
var bounce_count: int = 0 setget set_bounce_count
const max_bounce_range := 10

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
        
    if is_instance_valid(target):
        transform.basis = Transform.IDENTITY.looking_at(vel, Vector3.UP).basis

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

    if bounce_count > 0:
        bounce_count -= 1
        bounce_to_other_target()
    else:
        queue_free()

func enemy_sort_dist(a, b):
    return a.global_transform.origin.distance_to(self.global_transform.origin) < b.global_transform.origin.distance_to(self.global_transform.origin)

func bounce_to_other_target():
    find_target(self.target, self.max_bounce_range)

# `other_than_this_enemy`: optional parameter, if specified,
# try to find a different target than that enemy
func find_target(other_than_this_enemy = null, max_range = INF):
    var enemies = get_tree().get_nodes_in_group("enemies")
    var enemies_sorted = ArrayExtra.filter_by_method(enemies, "can_attack")
    enemies_sorted.sort_custom(self, "enemy_sort_dist")

    for enemy in enemies_sorted:
        if enemy != other_than_this_enemy and enemy.global_transform.origin.distance_to(global_transform.origin) < max_range:
            self.target = enemy
            return
    
    # no suitable enemy was found, self-destruct
    queue_free()

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

func set_bounce_count(val: int):
    bounce_count = int(max(0, val))
