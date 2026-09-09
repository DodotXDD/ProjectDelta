extends Node3D

var weapons = []
var selected_weapon = 0

func _ready() -> void:
	for w in self.get_children():
		weapons.append(w)
		w.visible = false
		w.anim.play("Unequip")
	weapons[selected_weapon].visible = true
	weapons[selected_weapon].anim.play("Equip")

func _process(_delta):
	if Input.is_action_just_pressed("next_weapon"):
		weapon_change(1)
	elif Input.is_action_just_pressed("previous_weapon"):
		weapon_change(-1)

func weapon_change(direction):
	weapons[selected_weapon].anim.play("Unequip")
	selected_weapon += direction
	if (selected_weapon < 0):
		selected_weapon += weapons.size()
	elif selected_weapon >= weapons.size():
		selected_weapon -= weapons.size()
		
	weapons[selected_weapon].visible = true
	weapons[selected_weapon].anim.play("Equip")
