extends Spatial

onready var init_pos = global_transform[3]

export var max_speed := 5.0
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

    global_transform.origin.x = cos(PI/2 + PI * 0.5 * sin(elapsed)) * max_range
    global_transform.origin.z = sin(PI/2 + PI * 0.5 * sin(elapsed)) * max_range
    
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
        spawn_bouncing_projectile(target)

    # enemy death
    if target.health <= 0:
        var experience = experience_scene.instance()
        experience.transform = target.transform
        get_tree().get_root().add_child(experience)
        target.queue_free()

func spawn_bouncing_projectile(just_hit_enemy):
    var projectile = projectile_scene.instance()
    projectile.max_speed = 50.0
    projectile.max_steer_force = 350
    projectile.damage = GlobalVars.projectile_damage / 2
    projectile.knockback_force = GlobalVars.knockback_force
    projectile.transform.origin = self.global_transform.origin
    projectile.bounce_count = self.bounce_count - 1

    get_tree().get_root().add_child(projectile)

    # Tell the projectile to hit a different enemy than the one we just hit
    projectile.find_target(just_hit_enemy, projectile.max_bounce_range)

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()

func current_max_distance(target_position: Vector3) -> float:
    return (target_position - init_pos).length()
