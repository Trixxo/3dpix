extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target = Vector3(0, 4, 0)

var health = GlobalVars.enemy_health

var effective_health = health setget set_effective_health

var hit_anim_timer = 0

var hit_dir = Vector3.ZERO

var base_scale = Vector3.ONE

var sorted_enemy_group

# Called when the node enters the scene tree for the first time.
func _ready():
    base_scale = scale

func play_hit_animation(dir):
    hit_anim_timer = 1
    hit_dir = dir

func set_effective_health(val):
    effective_health = val
    # don't include this in new searches for enemies to kill
    if effective_health <= 0:
        remove_from_group("enemies")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    if hit_anim_timer > 0:
        scale = base_scale - sin(hit_anim_timer * PI) * hit_dir * 0.5
        hit_anim_timer -= dt * 5.0
    else:
        hit_anim_timer = 0
    # if hit_anim_timer > 0:
    # 	global_transform.origin += hit_dir.normalized() * 1.5
    # 	hit_anim_timer -= dt

    global_transform = global_transform.translated((target - transform[3]).normalized() * 0.5 * dt)

    if (not is_in_group("enemies") 
            and global_transform.origin.distance_to(Vector3(0, 0, 0)) <= GlobalVars.main_tower_range):
        add_to_group("enemies")
    elif (is_in_group("enemies") 
            and global_transform.origin.distance_to(Vector3(0, 0, 0)) > GlobalVars.main_tower_range):
        remove_from_group("enemies")
    
