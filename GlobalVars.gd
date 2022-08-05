extends Node

# enemy related
var enemy_health := 2

# projectile related
var attack_speed := 1.0
var projectile_damage := 1.0
var knockback_force := 0.0
var main_tower_range := 50

# experience related
var experience := 0
var experience_sentinels := 1

var red_towers = 0

# emitted when a new tower is built, with arguments:
# 1. all towers built so far
# 2. new tower built just now
signal update

func tower_built(all_types: Array, type: int):
    match Towers.color_for_tower(type):
        Towers.ColorGroup.Red:
            if red_towers == 0:
                var triangle_main_tower = preload("res://MainTower/TriangleMainTower.tscn").instance()
                get_tree().get_root().add_child(triangle_main_tower)
            red_towers += 1

    match type:
        Towers.Type.ThreeSpheres:
            GlobalVars.experience_sentinels += 1
        Towers.Type.Weight:
            GlobalVars.knockback_force += 1.0

    emit_signal("update", all_types, type)

static func clamp(vec: Vector3, length: float) -> Vector3:
    if (vec.length() > length):
        return vec.normalized() * length
    else:
        return vec

static func rand_vec_on_sphere() -> Vector3:
    var angle = randf() * 2.0 * PI
    var z = randf() * 2.0 - 1.0
    var result = Vector3(sqrt(1.0 - pow(z, 2)) * cos(angle), sqrt(1.0 - pow(z, 2)) * sin(angle), z)
    if (result.y < 0):
        result = rand_vec_on_sphere()
    return result
