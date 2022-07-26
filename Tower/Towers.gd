class_name Towers

enum Type {
    Prism,
    Cube,
    ThreeSpheres,
    Weight,
    Cylinder,
    FlatSphere,
    StretchedSphere,
    Stick,
    Bomb,
    Lightning,
    Pot,
    Halo,
    TwoTriangles
}

enum ColorGroup {
    Red,
    Blue,
    Yellow,
    Green,
    Purple,
    None,
}

static func get_base_types():
    return [Type.Halo, Type.Pot, Type.Cylinder, Type.Cube, Type.Prism, Type.FlatSphere, Type.StretchedSphere, Type.Bomb, Type.Stick, Type.Lightning]

static func get_upgrade_types() -> Array:
    return [Type.Weight, Type.TwoTriangles]

static func description_for_tower(tower_type) -> String:
    match tower_type:
        Type.Cylinder:
            return "+1 ATTACK SPEED"
        Type.TwoTriangles:
            return "[stack] + projectile speed"
        Type.Halo:
            return "SHOOT FASTER"
        Type.FlatSphere:
            return "+1 PROJECTILE BAM"
        Type.StretchedSphere:
            return "+1 PROJECTILE"
        Type.Cube:
            return "KNOCKS ENEMIES BACK"
        Type.Prism:
            return "STUNS ENEMIES"
        Type.Stick:
            return "+1 PROJECTILE"
        Type.Bomb:
            return "+1 PROJECTILE"
        Type.ThreeSpheres:
            return "+1 EXPERIENCE SENTINEL"
        Type.Weight:
            return "[stack] BONUS ATTACK SPEED FOR ALL"
        Type.Lightning:
            return "CHAIN LIGHTNING BOOM"
        Type.Pot:
            return "POISON SPLASH"
        _:
            printerr("no description for tower: ", tower_type)
            return ""

static func color_for_tower(type):
    match type:
        Type.Cylinder, Type.Cube, Type.Prism, Type.TwoTriangles:
            return ColorGroup.Red
        Type.FlatSphere, Type.StretchedSphere, Type.Lightning:
            return ColorGroup.Blue
        Type.Stick, Type.Bomb:
            return ColorGroup.Yellow
        Type.Pot:
            return ColorGroup.Green
        Type.Halo:
            return ColorGroup.Purple
        Type.Weight, Type.ThreeSpheres:
            return ColorGroup.None
        _:
            printerr("No color for tower type defined: ", type)
            return null

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        Type.Cylinder:
            return preload("res://Tower/RedTower/CylinderTower.tscn")
        Type.TwoTriangles:
            return preload("res://Tower/RedTower/TwoTriangleTower.tscn")
        Type.Halo:
            return preload("res://Tower/PurpleTower/HaloTower.tscn")
        Type.Pot:
            return preload("res://Tower/GreenTower/PotTower.tscn")
        Type.FlatSphere:
            return preload("res://Tower/BlueTower/FlatSphereTower.tscn")
        Type.StretchedSphere:
            return preload("res://Tower/BlueTower/StretchedSphere.tscn")
        Type.Cube:
            return preload("res://Tower/CubeTower.tscn")
        Type.Prism:
            return preload("res://Tower/PrismTower.tscn")
        Type.Stick:
            return preload("res://Tower/YellowTower/StickTower.tscn")
        Type.Bomb:
            return preload("res://Tower/YellowTower/BombTower.tscn")
        Type.ThreeSpheres:
            return preload("res://Tower/ThreeSpheresTower.tscn")
        Type.Weight:
            return preload("res://Tower/WeightTower.tscn")
        Type.Lightning:
            return preload("res://Tower/BlueTower/Lightning.tscn")
    
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
                return not existing_types.empty()
            Type.ThreeSpheres:
                return existing_types.empty()
            Type.TwoTriangles:
                return not existing_types.empty() and color_for_tower(existing_types[0]) == ColorGroup.Red
            _:
                printerr("No build condition for tower type defined: ", type)
                return false

# return all tower types that can be built on at least one of the hexagons.
static func buildable_types(hexagons: Array) -> Array:
    # tower types that can only be built once
    var available_types = []
    for type in Type.values():
        for hexagon in hexagons:
            if (type in get_base_types() and not type in built_types(hexagons)) or not type in get_base_types() or type == Type.ThreeSpheres:
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
