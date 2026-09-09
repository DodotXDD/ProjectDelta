extends Label

@export var player: CharacterBody3D

func _process(_delta):
	if player == null:
		return

	var speed = Vector3(player.velocity.x, 0, player.velocity.z).length()

	var state := "Idle"

	if speed > 0.1:
		if Input.is_action_pressed("sprint"):
			state = "Sprinting"
		else:
			state = "Walking"

	text = "FPS: %d\nState: %s\nPlayer Speed: %.2f m/s" % [
		Engine.get_frames_per_second(),
		state,
		speed
	]
