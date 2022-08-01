extends Spatial

var experience_needed := 5
var show_cards := false setget set_show_cards
onready var grid = $"/root/Node2D/HexGrid"

func _ready():
    for card in get_children():
        card.connect("click", self, "_card_clicked", [card])
        card.visible = show_cards
    var _e = GlobalVars.connect("update", self, "_global_vars_updated")

func _unhandled_input(event: InputEvent):
    if event.is_action_released("debug_show_cards"):
        self.show_cards = not show_cards

func _global_vars_updated():
    if GlobalVars.experience >= experience_needed and not show_cards:
        self.show_cards = true
        GlobalVars.experience -= experience_needed

func _card_clicked(card: MeshInstance):
    if grid.new_tower_type != null: return

    grid.start_building_tower(card.preview_node, card.tower_type)
    self.show_cards = false

func set_show_cards(val):
    show_cards = val

    if show_cards:
        # check if there are any build options to display
        var buildable_types = Towers.buildable_types(get_tree().get_nodes_in_group("hexagons"))
        if buildable_types.empty():
            show_cards = false
            return

        # pick a random build option for each card
        buildable_types.shuffle()
        for card in get_children():
            card.tower_type = buildable_types.pop_back()
            if card.tower_type == null: continue
            card.set_preview(Towers.scene_for_tower(card.tower_type))

    for card in get_children():
        if card.tower_type == null: continue
        card.animate_visibility(val)
        yield(get_tree().create_timer(0.1), "timeout")
