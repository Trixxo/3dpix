extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target = Vector3(0, 4, 0)

var health = GlobalVars.enemy_health setget set_health

var effective_health = health

var hit_anim_timer := 0.0

var hit_dir := Vector3.ZERO

var base_scale := Vector3.ONE

var sorted_enemy_group

var size := 2

var poison_duration = 0

export var move_speed := 1

var is_stunned := false
var stun_timer: Timer

var experience_scene = preload("res://Experience/Experience.tscn")
var sphere_expolsion_scene = preload("res://Projectile/ParticleDamage.tscn")

func _ready():
    stun_timer = Timer.new()
    add_child(stun_timer)
    var _e = stun_timer.connect("timeout", self, "stun_finished")
    stun_timer.set_one_shot(true)

    add_to_group("enemies")

func play_hit_animation(dir):
    hit_anim_timer = 1
    hit_dir = dir

func stun(duration: float):
    if duration <= 0.0: return

    is_stunned = true
    stun_timer.start(duration)

func stun_finished():
    is_stunned = false

func can_attack() -> bool:
    return (effective_health > 0
        and global_transform.origin.distance_to(Vector3(0, 0, 0)) <= GlobalVars.main_tower_range)

func hit(projectile, type, damage, knockback_force = 0, stun_duration = 0):
    play_hit_animation(global_transform.origin - projectile.global_transform.origin)
    var sphere_explosion = sphere_expolsion_scene.instance()
    sphere_explosion.transform.origin = global_transform.origin
    get_tree().get_root().add_child(sphere_explosion)
    sphere_explosion.get_node("Particles").emitting = true
    sphere_explosion.get_node("Particles2").emitting = true
    var vec_to_target = global_transform.origin - projectile.global_transform.origin
    sphere_explosion.rotate_object_local(Vector3(0, 1, 0), atan2(vec_to_target.z, -vec_to_target.x))

    if knockback_force != 0:
        var knockback_dir = Vector3(vec_to_target.x, 0, vec_to_target.z).normalized()
        global_transform.origin += (knockback_dir * knockback_force)
    if stun_duration >= 0.0:
        stun(stun_duration)

    self.health -= damage

func _process(dt):
    transform.basis = Basis().scaled(base_scale)

    if is_stunned: 
        transform.basis = transform.basis \
            .rotated(Vector3.RIGHT, PI * 0.1) \
            .rotated(Vector3.UP, 8 * stun_timer.time_left)
        scale.y = base_scale.y * 0.4

    if hit_anim_timer > 0:
        scale.x = base_scale.x - sin(hit_anim_timer * PI) * 0.5
        hit_anim_timer -= dt * 5.0
    else:
        hit_anim_timer = 0
        scale.x = base_scale.x

    if not is_stunned:
        global_transform = global_transform.translated((target - transform[3]).normalized() * move_speed * dt)

func set_health(val: float):
    health = val
    if health < effective_health:
        self.effective_health = health

    if health <= 0:
        var experience = experience_scene.instance()
        experience.transform = transform
        get_tree().get_root().add_child(experience)
        queue_free()
