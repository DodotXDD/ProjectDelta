extends Control
class_name PlayerCard

signal ready_toggled(is_ready: bool)

@onready var label_name: Label = $Label
@onready var button_ready: Button = $Button

var is_ready := false
var card_owner_id: int  # The ID of the player this card represents

func _ready() -> void:
	card_owner_id = name.to_int()
	label_name.text = "Player " + str(card_owner_id)
	
	# Check if this card represents the HOST (server, peer ID 1)
	if card_owner_id == 1:
		# This is the HOST card - always show HOST regardless of who's viewing
		button_ready.text = "HOST"
		button_ready.disabled = true
		is_ready = true  # Host is always "ready"
	else:
		# This card represents a CLIENT
		# Check if this is MY card (the local player's card)
		if card_owner_id == multiplayer.get_unique_id():
			# This is MY card as a client - allow me to toggle ready
			button_ready.pressed.connect(_on_ready_pressed)
			button_ready.text = "Ready ❌"
		else:
			# This is ANOTHER player's card - show their state but disable button
			button_ready.disabled = true
			button_ready.text = "Ready ❌"

func _on_ready_pressed() -> void:
	is_ready = !is_ready
	button_ready.text = "Ready ✅" if is_ready else "Ready ❌"
	ready_toggled.emit(is_ready)

# Called by lobby to sync ready state across clients
func set_ready_state(ready: bool) -> void:
	is_ready = ready
	
	# Don't update HOST button
	if card_owner_id == 1:
		button_ready.text = "HOST"
		return
	
	# Update client ready button
	button_ready.text = "Ready ✅" if is_ready else "Ready ❌"
