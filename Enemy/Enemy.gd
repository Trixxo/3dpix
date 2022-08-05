extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target = Vector3(0, 4, 0)

var health = GlobalVars.enemy_health

var effective_health = health

var hit_anim_timer := 0.0

var hit_dir := Vector3.ZERO

var base_scale := Vector3.ONE

var sorted_enemy_group

export var move_speed := 2

var is_stunned := false
var stun_timer: Timer

func _ready():
    scale = base_scale

    add_to_group("enemies")

func play_hit_animation(dir):
    hit_anim_timer = 1
    hit_dir = dir

func stun(duration: float):
    if duration <= 0.0: return

    is_stunned = true

    if is_instance_valid(stun_timer):
        stun_timer.stop()
        stun_timer.queue_free()
    stun_timer = Timer.new()
    add_child(stun_timer)
    var _e = stun_timer.connect("timeout", self, "stun_finished")
    stun_timer.wait_time = duration
    stun_timer.set_one_shot(true)
    stun_timer.start()

func stun_finished():
    is_stunned = false

func can_attack() -> bool:
    return (effective_health > 0
        and global_transform.origin.distance_to(Vector3(0, 0, 0)) <= GlobalVars.main_tower_range)

func _process(dt):
    if hit_anim_timer > 0:
        scale = base_scale - sin(hit_anim_timer * PI) * hit_dir * 0.5
        hit_anim_timer -= dt * 5.0
    else:
        hit_anim_timer = 0
        scale = base_scale

    if is_stunned: 
        scale.y = base_scale.y * 0.7
        return

    global_transform = global_transform.translated((target - transform[3]).normalized() * move_speed * dt)
