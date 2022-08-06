class_name Towers

enum Type {
    Prism,
    Cube,
    ThreeSpheres,
    Weight,
    Cylinder,
    FlatSphere,
    StretchedSphere,
}

enum ColorGroup {
    Red,
    Blue,
    None
}

static func get_base_types():
    return [Type.Cylinder, Type.Cube, Type.Prism, Type.FlatSphere, Type.StretchedSphere, Type.ThreeSpheres]

static func get_upgrade_types() -> Array:
    return [Type.Weight]

static func color_for_tower(type):
    match type:
        Type.Cylinder, Type.Cube, Type.Prism:
            return ColorGroup.Red
        Type.Weight, Type.ThreeSpheres:
            return ColorGroup.None
        Type.FlatSphere, Type.StretchedSphere:
            return ColorGroup.Blue
        _:
            printerr("No color for tower type defined: ", type)
            return null

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        Type.Cylinder:
            return preload("res://Tower/RedTower/CylinderTower.tscn")
        Type.FlatSphere:
            return preload("res://Tower/BlueTower/FlatSphereTower.tscn")
        Type.StretchedSphere:
            return preload("res://Tower/BlueTower/StretchedSphere.tscn")
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
    var base_types = get_base_types()
    if type in base_types:
        return existing_types.empty()
    else:
        match type:
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
            if (type in get_base_types() and not type in built_types(hexagons)) or not type in get_base_types():
                if can_build_type(type, hexagon.tower_types): 
                    available_types.append(type)
                    break
    return available_types

static func built_types(hexagons: Array) -> Array:
    var built_types = []
    for hexagon in hexagons:
        for hex_type in hexagon.tower_types:
            if not hex_type in built_types:
                built_types.append(hex_type)
    return built_types
