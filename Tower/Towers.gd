class_name Towers

enum Type {
    Prism,
    Cube,
    ThreeSpheres,
    Weight
}

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        Type.Cube:
            return preload("res://MainTower/TriangleMainTower.tscn")
        Type.Prism:
            return preload("res://Tower/PrismTower.tscn")
        Type.ThreeSpheres:
            return preload("res://Tower/ThreeSpheresTower.tscn")
        Type.Weight:
            return preload("res://Tower/WeightTower.tscn")
    
    printerr("No scene for tower type defined: ", tower_type)
    return null

static func random_tower_type():
    var keys = Type.keys()
    return Type[keys[randi() % keys.size()]]

static func apply_tower_effect(tower_type) -> void:
    match tower_type:
        Type.Cube:
            return
            # GlobalVars.projectile_damage += 0.2
        Type.Prism:
            GlobalVars.attack_speed += 0.2
        Type.ThreeSpheres:
            GlobalVars.experience_sentinels += 1
        Type.Weight:
            GlobalVars.knockback_force += 1.0
        _:
            printerr("No effect for tower type defined: ", tower_type)
