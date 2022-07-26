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

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemies = get_tree().get_nodes_in_group("enemeies")

	base_scale = scale

	add_to_group("enemies")

func play_hit_animation(dir):
	hit_anim_timer = 1
	hit_dir = dir

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

	global_transform = global_transform.translated((target - transform[3]).normalized() * 2 * dt)
