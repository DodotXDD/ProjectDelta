extends Node3D
class_name DemoWorld

const PORT = 1027
const MAX_CLIENTS = 3
const IP_ADDRESS = "127.0.0.1"

var peer = ENetMultiplayerPeer.new()
var game_started = false  # Track if we're in-game or in lobby

@export var player_scene: PackedScene
@export var UI: CanvasLayer
@onready var panel: Panel = $UI/Panel

signal toggleClient
signal toggledHost

func _ready() -> void:
	EventSystem.exitGame.connect(exit_game)
	MusicController.play_stream(MusicController.music_2)

	toggleClient.connect(_on_join_pressed)
	toggledHost.connect(_on_host_pressed)

	print("Connected to exitGame signal")

func _on_host_pressed() -> void:
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	# Don't add players yet - wait for lobby to finish
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	UI.hide()
	_load_lobby()

func _on_join_pressed() -> void:
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	UI.hide()
	_load_lobby()

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected:", id)
	# Only handle disconnects during gameplay
	if game_started and has_node(str(id)):
		delete_player(id)

func _load_lobby():
	var lobby_scene = preload("res://Demo/lobby.tscn").instantiate()
	add_child(lobby_scene)

	lobby_scene.started_game.connect(func():
		print("Lobby started game; loading players...")
		game_started = true
		lobby_scene.queue_free()
		start_game()
	)

func start_game():
	print("Setting up players...")
	if multiplayer.is_server():
		# Server spawns all players
		for id in multiplayer.get_peers():
			add_player(id)
		add_player(multiplayer.get_unique_id())
	else:
		# Client only spawns their own player
		add_player(multiplayer.get_unique_id())
	print("Game world ready!")

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id):
	print("Exiting player id:", id)
	
	# Notify other players this player is leaving
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		rpc("_delete_player", id)
	elif multiplayer.has_multiplayer_peer():
		# Client notifies server they're leaving
		rpc_id(1, "_client_leaving", id)
	
	# Clean up local peer
	if multiplayer.has_multiplayer_peer():
		peer.close()
		multiplayer.multiplayer_peer = null
	
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

@rpc("any_peer", "call_remote")
func _client_leaving(id: int) -> void:
	if multiplayer.is_server():
		print("Client", id, "is leaving")
		# Server will handle via peer_disconnected signal

func delete_player(id):
	if not has_node(str(id)):
		print("Player node", id, "does not exist.")
		return

	print("Deleting player:", id)
	if multiplayer.is_server():
		rpc("_delete_player", id)
	_delete_player(id)

@rpc("authority", "call_local")
func _delete_player(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()
		print("Deleted player node:", id)
	else:
		print("Warning: Tried to delete missing player node:", id)
