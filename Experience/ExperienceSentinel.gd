extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rand_dir
var target = null
var target_vec = null
var original_move_speed = 3.0
var lerped_speed
var original_target_dist

# Called when the node enters the scene tree for the first time.
func _ready():
    rand_dir = [-1, 1][randi()%2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    if target == null:
        # idle_movement()
        find_target()

    if is_instance_valid(target):
        var dir = target_vec - global_transform.origin
        lerped_speed = lerp(0.4 * original_move_speed, original_move_speed, dir.length())
        var offset = dir.normalized() * dt * lerped_speed
        global_transform.origin += GlobalVars.clamp(offset, dir.length())

        if (target_vec != Vector3(0, 1, 0) and global_transform.origin.distance_to(target.global_transform.origin) < 1.0):
            target_vec = Vector3(0, 1, 0)

        if (target_vec == Vector3(0, 1, 0)):
            target.global_transform.origin = global_transform.origin
            if (global_transform.origin.distance_to(target_vec) < 0.1):
                target.queue_free()
                target = null
                target_vec = null

    rotate_object_local(Vector3.UP, dt * rand_dir)

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()
        
# func idle_movement():


func find_target():
    var exp_orbs = get_tree().get_nodes_in_group("experience_orbs")

    if not exp_orbs.size() > 0 : return

    exp_orbs.sort_custom(SortMan, "enemy_sort_dist")
    var first_orb = exp_orbs[0]
    target = first_orb
    target_vec = first_orb.global_transform.origin
    original_target_dist = target_vec.length()
    target.remove_from_group("experience_orbs")
