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
            return preload("res://Tower/CubeTower.tscn")
        Type.Prism:
            return preload("res://Tower/PrismTower.tscn")
        Type.ThreeSpheres:
            return preload("res://Tower/ThreeSpheresTower.tscn")
        Type.Weight:
            return preload("res://Tower/WeightTower.tscn")
    
    printerr("No scene for tower type defined: ", tower_type)
    return null

# check wether the given type can be built on a hexagon on top of the given existing types already built.
static func can_build_type(type: int, existing_types: Array) -> bool:
    match type:
        Type.Cube:
            return existing_types.empty()
        Type.Prism:
            return existing_types.empty()
        Type.ThreeSpheres:
            return existing_types.empty()
        Type.Weight:
            return Type.Cube in existing_types
        _:
            printerr("No build condition for tower type defined: ", type)
            return false

# return all tower types that can be built on at least one of the hexagons.
static func buildable_types(hexagons: Array) -> Array:
    var available_types = []
    for type in Type.values():
        for hexagon in hexagons:
            if can_build_type(type, hexagon.tower_types): 
                available_types.append(type)
                break
    return available_types

static func apply_tower_effect(tower_type: int, tree: SceneTree) -> void:
    match tower_type:
        Type.Cube:
            var triangle_main_tower = preload("res://MainTower/TriangleMainTower.tscn").instance()
            tree.get_root().add_child(triangle_main_tower)
        Type.Prism:
            GlobalVars.attack_speed += 0.2
        Type.ThreeSpheres:
            GlobalVars.experience_sentinels += 1
        Type.Weight:
            GlobalVars.knockback_force += 1.0
        _:
            printerr("No effect for tower type defined: ", tower_type)
