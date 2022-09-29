extends MeshInstance

var experience_sentinel_scene = preload("res://Experience/ExperienceSentinel.tscn")

onready var indicator = $'FillIndicator'

func _ready():
    var _e = GlobalVars.connect('tower_built', self, '_global_vars_updated')
    _global_vars_updated(null, null)

    _e = GlobalVars.connect('experience_changed', self, '_experience_changed')
    _experience_changed()

func _global_vars_updated(_all_types, _new_type):
    var existing_sentinels = get_tree().get_nodes_in_group("experience_sentinels").size()
    var sentinels_to_spawn = GlobalVars.experience_sentinels - existing_sentinels
    for _i in range(sentinels_to_spawn):
        var experience_sentinel = experience_sentinel_scene.instance()
        experience_sentinel.transform.origin.y = 1
        add_child(experience_sentinel)

func _experience_changed():
    var progress_factor = max(0, float(GlobalVars.experience) / GlobalVars.experience_needed)
    indicator.scale = Vector3(progress_factor, 1, progress_factor)
