extends Spatial

onready var init_pos = global_transform[3]

export var max_speed := 10.0
var speed := max_speed
var max_range := 10.0

var damage = GlobalVars.projectile_damage
var knockback_force = GlobalVars.knockback_force

var sphere_expolsion_scene = preload("ParticleDamage.tscn")
var experience_scene = preload("res://Experience/Experience.tscn")

var elapsed = 0

func _process(dt):
    elapsed += dt

    global_transform.origin.x = cos(elapsed * speed) * max_range
    global_transform.origin.z = sin(elapsed * speed) * max_range
    
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.size() > 0:
        for enemy in enemies:
            if (enemy.global_transform.origin.length() < max_range + 2) and (global_transform.origin.distance_to(enemy.global_transform.origin) < 1):
                hit_target(enemy)


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

    var knockback_dir = Vector3(vec_to_target.x, 0, vec_to_target.z).normalized()
    target.global_transform.origin += (knockback_dir * knockback_force)
    if target.health <= 0:
        var experience = experience_scene.instance()
        experience.transform = target.transform
        get_tree().get_root().add_child(experience)
        target.queue_free()

    queue_free()

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()

func current_max_distance(target_position: Vector3) -> float:
    return (target_position - init_pos).length()
