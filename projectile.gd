extends Spatial

onready var init_pos = global_transform[3]

export var max_speed = 40.0
var speed_factor = 0.6
var minimum_speed = 0.9 * max_speed
var speed = max_speed * speed_factor

var vel = Vector3.ZERO
var acc = Vector3.ZERO
var max_steer_force = 50
var steer_force = 0.2

var damage = GlobalVars.projectile_damage

var target = null

var enemy_scene = preload("res://Enemy.tscn")
var sphere_expolsion_scene = preload("res://Particle_Damage.tscn")

func _ready():
	# vel = (target.global_transform.origin - global_transform.origin).normalized() * speed
	pass

func _process(dt):
	steer_force = pow(speed_factor, 2) * max_steer_force
	speed = update_speed()
	acc += seek(target)
	vel += acc * dt
	vel = self.clamp(vel, speed)
	# rotation = vel
	# look_at(Vector3(1, 0, 0), Vector3.UP)
	# rotation.y = PI / 2.0
	transform.basis = Transform.IDENTITY.looking_at(vel, Vector3.UP).basis
	global_transform = global_transform.translated(Vector3.FORWARD * vel.length() * dt)
		
	if (target != null and is_instance_valid(target)):
		if (global_transform[3].distance_to(target.global_transform[3]) <= 1):
			hit_target()
	else:
		find_target()

func hit_target():
	target.play_hit_animation(target.global_transform.origin - global_transform.origin)
	target.health -= damage
	var sphere_explosion = sphere_expolsion_scene.instance()
	sphere_explosion.transform.origin = target.global_transform.origin
	get_tree().get_root().add_child(sphere_explosion)
	sphere_explosion.get_node("Particles").emitting = true
	sphere_explosion.get_node("Particles2").emitting = true
	var vec_to_target = target.global_transform.origin - global_transform.origin
	sphere_explosion.rotate_object_local(Vector3(0, 1, 0), atan2(vec_to_target.z, -vec_to_target.x))
	if target.health <= 0:
		target.queue_free()

	queue_free()

class SortMan:
	static func enemy_sort_dist(a, b):
		return a.transform.origin.length() < b.transform.origin.length()

func find_target():
	var enemies_sorted = get_tree().get_nodes_in_group("enemies")
	enemies_sorted.sort_custom(SortMan, "enemy_sort_dist")
	var i = 0
	while (enemies_sorted.size() > 0 and target == null and i < enemies_sorted.size()):
		target = enemies_sorted[i]
		if target.effective_health <= 0:
			target.remove_from_group("enemies")
			target = null
			i += 1
		else:
			target.effective_health -= damage



func seek(target) -> Vector3:
	var steer = Vector3.ZERO
	if is_instance_valid(target):
		var desired = (target.global_transform.origin - global_transform.origin).normalized() * speed
		steer = (desired - vel).normalized() * steer_force
	return steer

func update_speed() -> float:
	if is_instance_valid(target) and global_transform[3].length() < self.current_max_distance(target.global_transform[3]):
		speed_factor = global_transform[3].length() / self.current_max_distance(target.global_transform[3])

	return min(minimum_speed + speed_factor * max_speed, max_speed)

func clamp(vec: Vector3, length: float) -> Vector3:
	if (vec.length() > length):
		return vec.normalized() * speed
	else:
		return vec

func current_max_distance(target: Vector3) -> float:
	return (target - init_pos).length()
