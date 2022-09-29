extends Spatial

var rand_dir
var target = null
var target_vec = null
var original_move_speed = 1.9
var return_position

func _ready():
    add_to_group("experience_sentinels")
    rand_dir = [-1, 1][randi()%2] * (randf() + 0.2)
    return_position = global_transform.origin

func _process(dt):
    if target == null:
        set_idle(true)
        find_target()
    else:
        set_idle(false)


    if is_instance_valid(target):
        var target_offset = target_vec - global_transform.origin
        var move_progress = lerp(0.6 * original_move_speed, original_move_speed, target_offset.length())
        var offset = target_offset.normalized() * dt * move_progress
        global_transform.origin += GlobalVars.clamp(offset, target_offset.length())

        if (target_vec != return_position and global_transform.origin.distance_to(target.global_transform.origin) < 1.0):
            target_vec = return_position

        if (target_vec == return_position):
            target.global_transform.origin = global_transform.origin
            if (global_transform.origin.distance_to(target_vec) < 0.1):
                GlobalVars.experience += 1
                target.queue_free()
                target = null
                target_vec = null

    rotate_object_local(Vector3.UP, dt * rand_dir)

class SortMan:
    static func enemy_sort_dist(a, b):
        return a.transform.origin.length() < b.transform.origin.length()
        
func set_idle(val):
    if $SentinelChild1.idle:
        $SentinelChild1.idle = val
        $SentinelChild2.idle = val
        $SentinelChild3.idle = val
    else:
        $SentinelChild1.idle = val
        $SentinelChild2.idle = val
        $SentinelChild3.idle = val


func find_target():
    var exp_orbs = get_tree().get_nodes_in_group("experience_orbs")

    if not exp_orbs.size() > 0 : return

    exp_orbs.sort_custom(SortMan, "enemy_sort_dist")
    var first_orb = exp_orbs[0]

    if first_orb.vanished == true:
        find_target()

    target = first_orb
    target.picked_up = true
    target_vec = first_orb.global_transform.origin
    target.remove_from_group("experience_orbs")
