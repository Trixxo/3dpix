extends Node

# enemy related
var enemy_health := 2
var enemy_flight_height := 4

# projectile related
var attack_speed := 1.0
var projectile_damage := 1.0
var knockback_force := 0.0
var main_tower_range := 50

# experience related
var experience := 0 setget set_experience
var experience_sentinels := 1
# experience needed for the next card
var experience_needed := 3

var red_towers = 0
var blue_towers = 0
var yellow_towers = 0
var green_towers = 0
var purple_towers = 0

# emitted when a new tower is built, with arguments:
# 1. all towers built so far
# 2. new tower built just now
signal tower_built

# emitted when the experience amount changes.
signal experience_changed

func tower_built(all_types: Array, type: int):
    match Towers.color_for_tower(type):
        Towers.ColorGroup.Red:
            if red_towers == 0:
                var new_main = preload("res://MainTower/TriangleMainTower.tscn").instance()
                get_tree().get_root().add_child(new_main)
            red_towers += 1
        Towers.ColorGroup.Blue:
            if blue_towers == 0:
                var new_main = preload("res://MainTower/BlueMainTower.tscn").instance()
                get_tree().get_root().add_child(new_main)
            blue_towers += 1
        Towers.ColorGroup.Yellow:
            if yellow_towers == 0:
                var new_main = preload("res://MainTower/YellowMainTower.tscn").instance()
                get_tree().get_root().add_child(new_main)
            yellow_towers += 1
        Towers.ColorGroup.Green:
            if green_towers == 0:
                var new_main = preload("res://MainTower/GreenMainTower.tscn").instance()
                get_tree().get_root().add_child(new_main)
            green_towers += 1
        Towers.ColorGroup.Purple:
            if purple_towers == 0:
                var new_main = preload("res://MainTower/PurpleMainTower.tscn").instance()
                get_tree().get_root().add_child(new_main)
            purple_towers += 1

    match type:
        Towers.Type.ThreeSpheres:
            GlobalVars.experience_sentinels += 1
        Towers.Type.Weight:
            GlobalVars.attack_speed += 0.2

    emit_signal("tower_built", all_types, type)

func set_experience(val):
    experience = val
    emit_signal("experience_changed")

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
