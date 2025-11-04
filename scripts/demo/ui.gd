extends CanvasLayer

@onready var panel: Panel = $Panel


func _on_demo_multiplayer_toggle_client() -> void:
	#_switch_to_lobby()
	panel.hide()


func _on_demo_multiplayer_toggled_host() -> void:
	#_switch_to_lobby()
	panel.hide()


#func _switch_to_lobby() -> void:
	#panel.hide()
	#lobby.show()
