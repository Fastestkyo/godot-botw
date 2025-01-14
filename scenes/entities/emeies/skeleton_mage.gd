extends Enemy

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _ready() -> void:
	health = 3
func _on_timer_timeout() -> void:
	$Timers/Timer.wait_time = rng.randf_range(2,3)
	if position.distance_to(player.position) < attack_radius:
			$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)



func shoot_fireball() -> void:
	var dir = (player.position - position).normalized()
	var dir2d = Vector2(dir.x,dir.z)
	var pos = $skin/Rig/Skeleton3D/BoneAttachment3D/wand2/Marker3D.global_position
	
	cast_spell.emit("fireball", pos, dir2d,1.0)
