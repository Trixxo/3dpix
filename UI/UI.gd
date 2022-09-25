extends Spatial

var experience_needed := 3
var cards_visible := false setget set_cards_visible
var should_cards_be_visible := false
var is_animating = false

onready var grid = $"/root/Node2D/HexGrid"

func _ready():
    for card in get_children():
        card.connect("click", self, "_card_clicked", [card])
        card.visible = false

    var _e = GlobalVars.connect("experience_changed", self, "_experience_changed")
    var _e2 = GlobalVars.connect("tower_built", self, "_tower_built")

    # wait for initial hexagons to be spawned
    # (the "hexagons" group is slow to change)
    yield(get_tree().create_timer(0.5), "timeout")
    # show cards for picking an initial tower
    GlobalVars.experience += experience_needed

func _unhandled_input(event: InputEvent):
    if event.is_action_released("debug_show_cards"):
        if not cards_visible: shuffle_cards()
        self.cards_visible = not cards_visible

func _experience_changed():
    if (GlobalVars.experience >= experience_needed 
        and not cards_visible 
        and grid.new_tower_type == null):

        shuffle_cards()
        self.cards_visible = true

func _tower_built(_all, _new):
    GlobalVars.experience = GlobalVars.experience - experience_needed

func _card_clicked(card: MeshInstance):
    if grid.new_tower_type != null: return

    grid.start_building_tower(card.preview_node, card.tower_type)
    self.cards_visible = false

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
        card.get_node("Label").text = Towers.description_for_tower(card.tower_type)


func set_cards_visible(val):
    should_cards_be_visible = val

    if is_animating or cards_visible == val:
        return

    is_animating = true
    cards_visible = val

    var cards = get_children()
    for card in cards:
        if card.tower_type == null: continue
        card.animate_visibility(val)
        yield(get_tree().create_timer(0.1), "timeout")

    is_animating = false

    # if the value has changed while animating, re-set it to the value it should have
    if should_cards_be_visible != cards_visible:
        self.set_cards_visible(should_cards_be_visible)
