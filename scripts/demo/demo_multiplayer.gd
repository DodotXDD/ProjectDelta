extends Node3D
class_name DemoWorld

const PORT = 1027
const MAX_CLIENTS = 3

const IP_ADDRESS = "127.0.0.1"

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	EventSystem.exitGame.connect(exit_game)

func _on_host_pressed() -> void:
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(add_player)
	add_player()
	
	canvas_layer.hide()


func _on_join_pressed() -> void:
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
	
func exit_game(id):
	multiplayer.peer_disconnected.connect(delete_player)
	delete_player(id)
	
func delete_player(id):
	rpc("_delete_player", id)
	
@rpc("any_peer", "call_local")
func _delete_player(id):
	get_node(str(id)).queue_free()
	
