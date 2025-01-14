extends Control
@onready var stamina_bar: TextureProgressBar = $StaminaBar/CenterContainer/MarginContainer/TextureProgressBar
@onready var energy_bar: TextureProgressBar = $EnergyBar/MarginContainer/TextureProgressBar
@onready var spell_Texture = $Spells/MarginContainer/TextureRect
@onready var heart_cont = $Hearts/MarginContainer/HBoxContainer
var heart_tscn = preload("res://scenes/entities/ui/heart.tscn")
var fire_texture = preload("res://graphics/ui/fire.png")
var heal_texture = preload("res://graphics/ui/heal.png")

func setup(val:int):
	for i in val:
		var heart = heart_tscn.instantiate()
		heart_cont.add_child(heart)
		heart.change_alpha(1.0)
		await get_tree().create_timer(0.3).timeout


func upd_health(val:int, dir:int):
	for child in heart_cont.get_children():
		child.queue_free()
	if dir < 0:
		for i in val:
			var heart = heart_tscn.instantiate()
			heart_cont.add_child(heart)
		var extra_heart = heart_tscn.instantiate()
		heart_cont.add_child(extra_heart)
		extra_heart.change_alpha(0.0)
	else:
		for i in val -1 :
			var heart = heart_tscn.instantiate()
			heart_cont.add_child(heart)
		var extra_heart = heart_tscn.instantiate()
		heart_cont.add_child(extra_heart)
		extra_heart.change_alpha(1.0) 

func upd_spell(spells, current_spell):
	if current_spell == spells.FIREBALL:
		spell_Texture.texture = fire_texture
	elif current_spell == spells.HEAL:
		spell_Texture.texture = heal_texture

func upd_energy(val:int):
	energy_bar.value = val

func upd_stamina(current:int, target:int):
	var tween = create_tween()
	tween.tween_method(_change_stamina,current,target, 0.25)

func _change_stamina(val:int):
	stamina_bar.value = val

func change_stamina_vis(value:float):
	var tween = create_tween()
	tween.tween_method(_change_alpha, 1.0 - value,value,0.25)

func _change_alpha(val:float):
	stamina_bar.modulate.a = val
