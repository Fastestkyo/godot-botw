extends Node3D

var can_dmg :=false


func _process(_delta: float) -> void:
	if can_dmg:
		var collision = $RayCast3D.get_collider()
		if collision and "hit" in collision:
			collision.hit()
