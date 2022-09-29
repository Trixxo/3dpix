extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var enemies
var radius = 8
var tick_damage = 0.5
var duration = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
    enemies = get_tree().get_nodes_in_group("enemies")
    yield(get_tree().create_timer(2.0), "timeout")
    queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
    for enemy in enemies:
        var offset_pos = global_transform.origin + Vector3(0, 5.0, 0)
        if (is_instance_valid(enemy) and enemy.global_transform.origin.distance_to(offset_pos) < radius):
            if enemy.poison_duration <= 0:
                enemy.health -= tick_damage
                enemy.poison_duration = duration
            else:
                enemy.poison_duration -= dt
