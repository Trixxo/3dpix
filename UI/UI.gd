extends Spatial

enum TowerTypes {
    Prism = 1,
    Cube = 2
}

static func scene_for_tower(tower_type) -> Resource:
    match tower_type:
        TowerTypes.Cube:
            return preload("res://Tower/CubeTower.tscn")
        TowerTypes.Prism:
            return preload("res://Tower/PrismTower.tscn")
    
    printerr("No scene for tower type defined: ", tower_type)
    return null

func random_tower_type():
    var keys = TowerTypes.keys()
    return TowerTypes[keys[randi() % keys.size()]]
    

func _ready():
    for card in get_children():
        card.connect("click", self, "_card_clicked", [card])
        var type = random_tower_type()
        card.add_preview(scene_for_tower(type))
        card.hide()

func _unhandled_input(event: InputEvent):
    if event.is_action_released("debug_show_cards"):
        for card in get_children():
            card.show()

func _card_clicked(card: MeshInstance):
    $"/root/Node2D/HexGrid".start_building_tower(card.preview_node)
    for card in get_children():
        card.hide()

