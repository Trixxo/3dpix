extends Spatial

onready var init_pos = global_transform[3]

export var max_speed := 10.0
var speed := max_speed
var max_range := 10.0

var damage = GlobalVars.projectile_damage
var knockback_force = GlobalVars.knockback_force
var bounce_count := 0

var sphere_expolsion_scene = preload("ParticleDamage.tscn")
var experience_scene = preload("res://Experience/Experience.tscn")
var projectile_scene = preload("res://Projectile/Projectile.tscn")

var elapsed = 0

func _process(dt):
    elapsed += dt * speed

    global_transform.origin.x = cos(elapsed) * max_range
    global_transform.origin.z = sin(elapsed) * max_range
    
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.size() > 0:
        for enemy in enemies:
            if (enemy.global_transform.origin.length() < max_range + 2) and (global_transform.origin.distance_to(enemy.global_transform.origin) < enemy.size):
                hit_target(enemy)

func update_position(index):
    elapsed = (2.0 * PI) / index

func hit_target(target):
    target.play_hit_animation(target.global_transform.origin - global_transform.origin)
    target.health -= damage
    var sphere_explosion = sphere_expolsion_scene.instance()
    sphere_explosion.transform.origin = target.global_transform.origin
    get_tree().get_root().add_child(sphere_explosion)
    sphere_explosion.get_node("Particles").emitting = true
    sphere_explosion.get_node("Particles2").emitting = true
    var vec_to_target = target.global_transform.origin - global_transform.origin
    sphere_explosion.rotate_object_local(Vector3(0, 1, 0), atan2(vec_to_target.z, -vec_to_target.x))

    # knockback
    var knockback_dir = Vector3(vec_to_target.x, 0, vec_to_target.z).normalized()
    target.global_transform.origin += (knockback_dir * knockback_force)

    # bouncing
    if self.bounce_count > 0:
        spawn_bouncing_projectile()

    # enemy death
    if target.health <= 0:
        var experience = experience_scene.instance()
        experience.transform = target.transform
        get_tree().get_root().add_child(experience)
        target.queue_free()

func spawn_bouncing_projectile():
    var all_enemies = get_tree().get_nodes_in_group("enemies")
    var enemies = ArrayExtra.filter_by_method(all_enemies, "can_attack")
    if enemies.size() <= 0:
        return

    var cube = projectile_scene.instance()
    cube.max_speed = 50.0
    cube.max_steer_force = 350
    cube.damage = GlobalVars.projectile_damage / 2
    cube.knockback_force = GlobalVars.knockback_force
    cube.transform.origin = self.global_transform.origin
    cube.bounce_count = self.bounce_count - 1

    get_tree().get_root().add_child(cube)

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()

func current_max_distance(target_position: Vector3) -> float:
    return (target_position - init_pos).length()
