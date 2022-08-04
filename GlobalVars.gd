extends Node

# enemy related
var enemy_health := 2 setget set_enemy_health

# projectile related
var attack_speed := 1.0 setget set_attack_speed
var projectile_damage := 1.0 setget set_projectile_damage
var knockback_force := 0.0 setget set_knockback_force
var main_tower_range := 50 setget set_main_tower_range

# experience related
var experience := 0 setget set_experience
var experience_sentinels := 1 setget set_experience_sentinels

var red_towers = 0

signal update

func color_increased(col):
    if col == "red":
        if red_towers == 0:
            var triangle_main_tower = preload("res://MainTower/TriangleMainTower.tscn").instance()
            get_tree().get_root().add_child(triangle_main_tower)
        red_towers += 1
        attack_speed = red_towers * 0.2
        emit_signal("update")

func set_main_tower_range(val):
    main_tower_range = val
    emit_signal("update")

func set_knockback_force(val):
    knockback_force = val
    emit_signal("update")

func set_attack_speed(val):
    attack_speed = val
    emit_signal("update")

func set_experience_sentinels(val):
    experience_sentinels = val
    emit_signal("update")

func set_enemy_health(val):
    enemy_health = val
    emit_signal("update")

func set_projectile_damage(val):
    projectile_damage = val
    emit_signal("update")

func set_experience(val):
    experience = val
    emit_signal("update")

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
