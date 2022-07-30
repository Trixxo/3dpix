extends Spatial

func _ready():
    for card in get_children():
        card.connect("click", self, "_card_clicked", [card])
        card.hide()

func _unhandled_input(event):
    if event.is_action_released("debug_show_cards"):
        for card in get_children():
            card.show()

func _card_clicked(card):
    $"/root/Node2D/HexGrid".start_building_tower(card.get_node("Preview"))
    for card in get_children():
        card.hide()

