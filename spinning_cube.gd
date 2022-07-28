extends Spatial

var cube_projectile_scene = preload("res://Cube_projectile.tscn")
var target_velocity
var _timer
var attack_speed = GlobalVars.attack_speed
var origin_rotation
var origin_transform
var interpolation_factor = 0

signal finished_interpolation

func _ready():
	# $AnimationPlayer3.play("spin")
	# instance_cube()
	if name == "spinning_cube":
		origin_transform = transform
		origin_rotation = transform.basis
		_timer = Timer.new()
		add_child(_timer)

		_timer.connect("timeout", self, "instance_cube")
		_timer.set_wait_time(1.0 / GlobalVars.attack_speed)
		_timer.set_one_shot(false)
		_timer.start()
	else:
		get_node("/root/Node2D/Viewport/spinning_cube").on_new_tower()

func _process(dt):
	if not name == "spinning_cube":
		rotation.y += dt

	if target_velocity != null:
		transform.basis = Basis(interpolate_quat(target_velocity, dt).get_euler())

func on_new_tower():
	GlobalVars.attack_speed += 0.2
	_timer.set_wait_time(1.0 / GlobalVars.attack_speed)

func instance_cube():
	var cube
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0 and target_velocity == null:
		cube = cube_projectile_scene.instance()
		cube.transform.origin.y = 4
		cube.vel = rand_vec_on_sphere() * cube.speed
		cube.transform = cube.transform.translated(cube.vel.normalized() * (self.mesh.mid_height / 2.0))

		target_velocity = cube.vel

		yield(self, 'finished_interpolation')
		get_tree().get_root().add_child(cube)

	
func interpolate_quat(target, dt):
	var origin_quat = Quat(origin_rotation)
	var target_transform = Transform.IDENTITY.looking_at(target, Vector3(0, 1, 0))
	# target_transform = target_transform.rotated(target_transform.basis.x, -PI / 2.0)
	var target_quat = Quat(target_transform.basis)
	if not origin_quat.is_normalized() or not target_quat.is_normalized():
		print("not normalized")

	if ((-transform.basis.z.normalized()).distance_to(target.normalized())) < 0.1:
		emit_signal('finished_interpolation')
		print("finished interpolation")
		origin_rotation = transform.basis
		interpolation_factor = 0
		target_velocity = null
		return Quat(transform.basis)
	else:
		interpolation_factor += min(1, dt * GlobalVars.attack_speed * 1.5)
		return origin_quat.normalized().slerp(target_quat.normalized(), interpolation_factor)


func rand_vec_on_sphere() -> Vector3:
	var angle = randf() * 2.0 * PI
	var z = randf() * 2.0 - 1.0
	var result = Vector3(sqrt(1.0 - pow(z, 2)) * cos(angle), sqrt(1.0 - pow(z, 2)) * sin(angle), z)
	if (result.y < 0):
		result = rand_vec_on_sphere()
	return result
