extends MeshInstance

var idle_movement_factor = 0
var idle_movement_speed = 0.3 + randf() * 0.2
var preview_node: Spatial
var is_animating = false
onready var initial_y = transform.origin.y
onready var camera = $'../../Camera'
onready var initial_scale = scale

signal click

func _ready():
    var _e = $Area.connect("mouse_entered", self, "_mouse_entered")
    var _e2 = $Area.connect("mouse_exited", self, "_mouse_exited")
    var _e3 = $Area.connect("input_event", self, "_area_input_event")
    # prevent flashing of animation "reset" position when first making the cards visible
    $AnimationPlayer.play("Appear")
    $AnimationPlayer.advance(0)
    $AnimationPlayer.stop(false)

func _process(dt):
    if is_animating or not visible: return
    idle_movement_factor += idle_movement_speed * dt
    transform.origin.x = 0.5 * sin(3 * sin(idle_movement_factor))
    transform.origin.y = initial_y + sin(idle_movement_factor * 0.5)
    self.rotation_degrees.z = 5 * sin(idle_movement_factor * 0.5)
    self.rotation_degrees.y = -10 + 10 * cos(idle_movement_factor)

func add_preview(scene: Resource):
    preview_node = scene.instance()
    preview_node.transform.origin.z = 1
    preview_node.transform = preview_node.transform.scaled(Vector3.ONE * 2)
    preview_node.cast_shadow = SHADOW_CASTING_SETTING_OFF
    add_child(preview_node)

func _mouse_entered():
    scale = initial_scale * 1.05

func _mouse_exited():
    scale = initial_scale

func _area_input_event(_cam, event, _position, _normal, _shape_index):
    if event.is_action_released("game_select"):
        emit_signal("click")

func animate_visibility(visible):
    is_animating = true
    if visible:
        $AnimationPlayer.play("Appear")
        self.visible = true
        yield($AnimationPlayer, "animation_finished")
        is_animating = false
    else:
        $AnimationPlayer.play_backwards("Appear")
        yield($AnimationPlayer, "animation_finished")
        is_animating = false
        self.visible = false
        # reset to match the calculated card transform to the end of the animation
        reset_transform()

func reset_transform():
    transform.origin.x = 0
    transform.origin.y = initial_y
    self.rotation_degrees.z = 0
    self.rotation_degrees.y = 0
    idle_movement_factor = 0
