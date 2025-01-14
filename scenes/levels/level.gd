class_name Level
extends Node3D
var firball_scene:PackedScene = preload("res://scenes/entities/vfx/fireball.tscn")
const scenes = {
	"overworld":"res://scenes/levels/overworld.tscn",
	"dungeon": "res://scenes/levels/dungeon.tscn",
	
}
func _ready() -> void:
	for entity in $Entities.get_children():
		if entity.has_signal("cast_spell"):
			entity.connect("cast_spell", create_fireball)
@warning_ignore("shadowed_variable_base_class")
func create_fireball(_type: String, position: Vector3, direction: Vector2, size: float):
	var fireball = firball_scene.instantiate()
	$Projectiles.add_child(fireball)
	fireball.global_position = position
	fireball.dir = direction
	fireball.setup(size)

func switch(level:String):
	call_deferred("_switch", level)
	

func _switch(level:String):
	get_tree().change_scene_to_file(scenes[level])
	
