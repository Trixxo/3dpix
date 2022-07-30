class_name Towers

enum Type {
    Prism,
    Cube,
    ThreeSpheres
}

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        Type.Cube:
            return preload("res://Tower/CubeTower.tscn")
        Type.Prism:
            return preload("res://Tower/PrismTower.tscn")
        Type.ThreeSpheres:
            return preload("res://Tower/ThreeSpheresTower.tscn")
    
    printerr("No scene for tower type defined: ", tower_type)
    return null

static func random_tower_type():
    var keys = Type.keys()
    return Type[keys[randi() % keys.size()]]

static func apply_tower_effect(tower_type) -> void:
    match tower_type:
        Type.Cube:
            GlobalVars.projectile_damage += 0.2
            return
        Type.Prism:
            GlobalVars.attack_speed += 0.2
            return
        Type.Prism:
            GlobalVars.experience_sentinels += 1
            return

    printerr("No effect for tower type defined: ", tower_type)
