class_name Towers

enum Type {
    Prism,
    Cube,
    ThreeSpheres,
    Weight,
    Cylinder,
}

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        Type.Cylinder:
            return preload("res://Tower/RedTower/CylinderTower.tscn")
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
        Type.Cylinder:
            return existing_types.empty()
        Type.Cube:
            return existing_types.empty()
        Type.Prism:
            return existing_types.empty()
        Type.ThreeSpheres:
            return existing_types.empty()
        Type.Weight:
            return Type.Cube in existing_types or Type.Prism in existing_types or Type.Cylinder in existing_types
        _:
            printerr("No build condition for tower type defined: ", type)
            return false

# return all tower types that can be built on at least one of the hexagons.
static func buildable_types(hexagons: Array) -> Array:
    # tower types that can only be built once
    var available_types = []
    for type in Type.values():
        for hexagon in hexagons:
            if (type in get_unique_types() and not type in built_types(hexagons)) or not type in get_unique_types():
                if can_build_type(type, hexagon.tower_types): 
                    available_types.append(type)
                    break
    return available_types

static func get_unique_types():
    return [Type.Cube, Type.Prism, Type.Cylinder]

static func built_types(hexagons: Array) -> Array:
    var built_types = []
    for hexagon in hexagons:
        for hex_type in hexagon.tower_types:
            if not hex_type in built_types:
                built_types.append(hex_type)
    return built_types

static func apply_tower_effect(tower_type: int) -> void:
    match tower_type:
        Type.Cube:
            GlobalVars.color_increased("red")
        Type.Prism:
            GlobalVars.color_increased("red")
        Type.ThreeSpheres:
            GlobalVars.experience_sentinels += 1
        Type.Weight:
            GlobalVars.knockback_force += 1.0
        Type.Cylinder:
            GlobalVars.color_increased("red")
        _:
            printerr("No effect for tower type defined: ", tower_type)
