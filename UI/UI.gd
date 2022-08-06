extends Spatial

var experience_needed := 3
var show_cards := false setget set_show_cards
var is_animating = false

onready var grid = $"/root/Node2D/HexGrid"

func _ready():
    for card in get_children():
        card.connect("click", self, "_card_clicked", [card])
        card.visible = false

    # wait for initial hexagons to be spawned
    # (the "hexagons" group is slow to change)
    yield(get_tree().create_timer(0.5), "timeout")
    # show cards for picking an initial tower
    shuffle_cards()
    self.show_cards = true
    var _e = GlobalVars.connect("experience_changed", self, "_experience_changed")

func _unhandled_input(event: InputEvent):
    if event.is_action_released("debug_show_cards"):
        if not show_cards: shuffle_cards()
        self.show_cards = not show_cards

func _experience_changed():
    if GlobalVars.experience >= experience_needed and not show_cards:
        shuffle_cards()
        self.show_cards = true
        GlobalVars.experience -= experience_needed

func _card_clicked(card: MeshInstance):
    if grid.new_tower_type != null: return

    grid.start_building_tower(card.preview_node, card.tower_type)
    self.show_cards = false

# Set a new random upgrade type for each card.
func shuffle_cards():
    # check if there are any build options to display
    var buildable_types = Towers.buildable_types(get_tree().get_nodes_in_group("hexagons"))

    # pick a random build option for each card
    buildable_types.shuffle()
    for card in get_children():
        card.tower_type = buildable_types.pop_back()
        if card.tower_type == null: continue
        card.set_preview(Towers.scene_for_tower(card.tower_type))


func set_show_cards(val):
    if is_animating or val == show_cards: 
        return

    is_animating = true
    show_cards = val

    var cards = get_children()
    for card in cards:
        if card.tower_type == null: continue
        card.animate_visibility(val)
        yield(get_tree().create_timer(0.1), "timeout")

    is_animating = false
    # check if the cards should open again
    _experience_changed()
