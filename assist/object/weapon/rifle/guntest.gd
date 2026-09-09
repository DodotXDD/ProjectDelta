extends Node3D

@export var damage = 10
@export var fire_rate = 0.2 # Seconds between shots (5 shots/sec)

@onready var anim = $anim
@onready var shot_sound = $shotsound
@onready var raycast = $RayCast3D

var can_shoot = true
var fire_timer = 0.0

func _process(_delta: float) -> void:
	if fire_timer > 0:
		fire_timer -= _delta

	if Input.is_action_pressed("shoot") and can_shoot and fire_timer <= 0:
		shoot()

func shoot():
	fire_timer = fire_rate
	can_shoot = false

	print("FIRE!")

	anim.play("Shoot")
	shot_sound.play()

	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.is_in_group("enemy"):
			target.hp -= damage

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name.to_lower():
		"shoot":
			can_shoot = true
		"equip":
			can_shoot = true
		"unequip":
			can_shoot = false
