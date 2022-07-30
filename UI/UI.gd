extends Spatial

func _ready():
    for card in get_children():
        var type = Towers.random_tower_type()
        card.connect("click", self, "_card_clicked", [card, type])
        card.add_preview(Towers.scene_for_tower(type))
        card.hide()

func _unhandled_input(event: InputEvent):
    if event.is_action_released("debug_show_cards"):
        for card in get_children():
            card.show()

func _card_clicked(card: MeshInstance, tower_type):
    $"/root/Node2D/HexGrid".start_building_tower(card.preview_node, tower_type)
    for card in get_children():
        card.hide()

