extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target = Vector3(0, 4, 0)

var health = GlobalVars.enemy_health

var effective_health = health

var hit_anim_timer = 0

var hit_dir = Vector3.ZERO

var base_scale = Vector3.ONE

var sorted_enemy_group

func _ready():
    base_scale = scale

    add_to_group("enemies")

func play_hit_animation(dir):
    hit_anim_timer = 1
    hit_dir = dir

func can_attack() -> bool:
    return (effective_health > 0
        and global_transform.origin.distance_to(Vector3(0, 0, 0)) <= GlobalVars.main_tower_range)

func _process(dt):
    if hit_anim_timer > 0:
        scale = base_scale - sin(hit_anim_timer * PI) * hit_dir * 0.5
        hit_anim_timer -= dt * 5.0
    else:
        hit_anim_timer = 0

    global_transform = global_transform.translated((target - transform[3]).normalized() * 0.5 * dt)
