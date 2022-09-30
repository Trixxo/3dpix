extends Spatial

export var max_speed := 100.0
var speed_factor := 0.6
var minimum_speed := 0.9 * max_speed
var speed := max_speed * speed_factor
var knockback_force := 0.0
var stun_duration := 0.0

var damage = GlobalVars.projectile_damage

# var target = null setget set_target
var target_dir := Vector3.ZERO

func _process(dt):
    if target_dir != Vector3.ZERO:
        global_transform = global_transform.translated(Vector3.FORWARD * dt * speed)
    
    if (target_dir.normalized().y != 1):
        transform.basis = Transform.IDENTITY.looking_at(target_dir.normalized(), Vector3.UP).basis

    for enemy in get_tree().get_nodes_in_group("enemies"):
        if (enemy.global_transform.origin - global_transform.origin).length() < 1:
            enemy.hit(self, Towers.ColorGroup.Purple, damage, knockback_force, stun_duration)
