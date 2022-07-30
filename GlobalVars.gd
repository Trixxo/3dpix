extends Node

var attack_speed = 1.0

var enemy_health = 5

var projectile_damage = 1

static func clamp(vec: Vector3, length: float) -> Vector3:
    if (vec.length() > length):
        return vec.normalized() * length
    else:
        return vec
