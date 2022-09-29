extends Spatial

onready var init_pos = global_transform[3]

export var max_speed := 40.0
var speed_factor := 0.6
var minimum_speed := 0.9 * max_speed
var speed := max_speed * speed_factor

var vel := Vector3.ZERO
var acc := Vector3.ZERO
var max_steer_force := 10
var steer_force := 4

var damage = GlobalVars.projectile_damage
var knockback_force = GlobalVars.knockback_force
var stun_duration = 0.0

# var target = null setget set_target
var target_dir := Vector3.ZERO

var enemy_scene = preload("res://Enemy/Enemy.tscn")
var sphere_expolsion_scene = preload("ParticleDamage.tscn")
var experience_scene = preload("res://Experience/Experience.tscn")

func _process(dt):
    # steer_force = pow(speed_factor, 2) * max_steer_force
    # speed = update_speed()
    if target_dir != Vector3.ZERO:

        # acc += target_dir.normalized() * steer_force
        # vel += acc * dt
        # vel = GlobalVars.clamp(vel, speed)
        

        global_transform = global_transform.translated(Vector3.FORWARD * dt * 20.0)
    
    # vel = GlobalVars.clamp(vel, speed)
    # rotation = vel
    # look_at(Vector3(1, 0, 0), Vector3.UP)
    # rotation.y = PI / 2.0
    if (vel.normalized().y != 1):
        transform.basis = Transform.IDENTITY.looking_at(target_dir.normalized(), Vector3.UP).basis
        
    # if target != null:
    #     var distance_to_target = global_transform[3].distance_to(target)
    #     # dont move further than the required distance to the target
    #     var step = min(distance_to_target - 1, vel.length() * dt)

    for enemy in get_tree().get_nodes_in_group("enemies"):
        if (enemy.global_transform.origin - global_transform.origin).length() < 1:
            enemy.health -= damage * 5.0

        # if ( distance_to_target <= 4):
        #     hit_target()
    # else:
    #     find_target()

func hit_target(target):
    # target.play_hit_animation(target.global_transform.origin - global_transform.origin)
    # target.health -= damage
    var sphere_explosion = sphere_expolsion_scene.instance()
    sphere_explosion.transform.origin = target
    get_tree().get_root().add_child(sphere_explosion)
    sphere_explosion.get_node("Particles").emitting = true
    sphere_explosion.get_node("Particles2").emitting = true
    var vec_to_target = target - global_transform.origin
    sphere_explosion.rotate_object_local(Vector3(0, 1, 0), atan2(vec_to_target.z, -vec_to_target.x))

    # var poison = poision_scene.instance()
    # poison.transform.origin = target
    # poison.transform.origin.y -= .8
    # get_tree().get_root().add_child(poison)

    # var knockback_dir = Vector3(vec_to_target.x, 0, vec_to_target.z).normalized()
    # target.global_transform.origin += (knockback_dir * knockback_force)
    # if stun_duration >= 0.0:
    #     target.stun(stun_duration)

    # if target.health <= 0:
    #     var experience = experience_scene.instance()
    #     experience.transform = target.transform
    #     get_tree().get_root().add_child(experience)
    #     target.queue_free()

    target = null
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
    var pos = first_enemy.global_transform.origin
    self.target = Vector3(pos.x, 0, pos.z)
