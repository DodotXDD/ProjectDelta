extends CharacterBody3D

const SPEED = 4.0

@export var player_path: NodePath
@onready var player = get_node(player_path)
@onready var nav_agent = $NavigationAgent3D

func _process(_delta):
	if not player:
		return
		
	# Move toward player
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	var direction = (next_nav_point - global_transform.origin).normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	# Make the bot look at the player (Y-axis only)
	var bot_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	
	player_pos.y = bot_pos.y  # Keep rotation flat (ignore vertical angle)
	look_at(player_pos, Vector3.UP)
