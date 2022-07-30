extends Node

var attack_speed = 1.0 setget set_attack_speed

var enemy_health = 5 setget set_enemy_health

var projectile_damage = 1 setget set_projectile_damage

var experience = 0 setget set_experience

signal update

func set_attack_speed(val):
    attack_speed = val
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
