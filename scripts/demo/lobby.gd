extends Control
class_name Lobby

@export var host_controls: Array[Control] = []
@export var start_button: Button
@export var quit_button: Button
@export var player_card: PackedScene
@export var hbox_player_cards: HBoxContainer

signal started_game

var player_ready: Dictionary = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	setup_screen()
	
	# Host controls visibility
	for ctrl in host_controls:
		ctrl.visible = multiplayer.is_server()
	start_button.disabled = true
	start_button.pressed.connect(_on_start_button_pressed)

func setup_screen() -> void:
	# Clear previous cards
	for child in hbox_player_cards.get_children():
		child.queue_free()

	# Add self card
	var my_id = multiplayer.get_unique_id()
	_add_player_card(my_id)

	# If server, add existing clients (shouldn't happen in this flow, but just in case)
	if multiplayer.is_server():
		for id in multiplayer.get_peers():
			_add_player_card(id)

func _on_peer_connected(id: int) -> void:
	_add_player_card(id)
	player_ready[id] = false
	_update_start_button_state()

func _on_peer_disconnected(id: int) -> void:
	if hbox_player_cards.has_node(str(id)):
		hbox_player_cards.get_node(str(id)).queue_free()
	player_ready.erase(id)
	_update_start_button_state()

func _add_player_card(id: int) -> void:
	var card = player_card.instantiate()
	card.name = str(id)
	hbox_player_cards.add_child(card)

	# Initialize ready state
	player_ready[id] = false

	# Connect ready signal for this card
	if card.has_signal("ready_toggled"):
		card.ready_toggled.connect(_on_card_ready_toggled.bind(id))

func _on_card_ready_toggled(is_ready: bool, id: int) -> void:
	# Only process if this is MY card
	if id != multiplayer.get_unique_id():
		return
	
	# Update local state
	player_ready[id] = is_ready
	
	# Notify server
	if multiplayer.is_server():
		# Server updates directly
		rpc("sync_ready_state", id, is_ready)
	else:
		# Client requests server to update
		rpc_id(1, "request_ready_update", id, is_ready)

@rpc("any_peer", "call_remote")
func request_ready_update(id: int, is_ready: bool) -> void:
	# Only server processes this
	if not multiplayer.is_server():
		return
	
	# Update server's state
	player_ready[id] = is_ready
	_update_start_button_state()
	
	# Broadcast to all clients
	rpc("sync_ready_state", id, is_ready)

@rpc("authority", "call_local")
func sync_ready_state(id: int, is_ready: bool) -> void:
	# Update ready state for all clients
	player_ready[id] = is_ready
	
	# Update the visual state of the card
	if hbox_player_cards.has_node(str(id)):
		var card = hbox_player_cards.get_node(str(id))
		if card.has_method("set_ready_state"):
			card.set_ready_state(is_ready)
	
	_update_start_button_state()

func _update_start_button_state() -> void:
	if not multiplayer.is_server():
		return

	# Must have at least 2 players (host + 1 client)
	if player_ready.size() < 2:
		start_button.disabled = true
		return

	# Only enable if all non-host players are ready
	for id in player_ready.keys():
		# Skip host
		if id == multiplayer.get_unique_id():
			continue
		# If any client is not ready, disable button
		if not player_ready[id]:
			start_button.disabled = true
			return

	# All clients ready
	start_button.disabled = false

func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		print("Host starting game...")
		rpc("load_game_scene")

@rpc("authority", "call_local")
func load_game_scene():
	started_game.emit()
