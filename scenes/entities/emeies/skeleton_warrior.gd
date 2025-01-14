extends Enemy

func _physics_process(delta: float) -> void:
	move_to_player(delta)
func _ready() -> void:
	health = 3


func _on_timer_timeout() -> void:
	$Timers/Timer.wait_time = rng.randf_range(2.5,3.5)
	if position.distance_to(player.position) < attack_radius:
		$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_dmg(value:bool):
	$skin/Rig/Skeleton3D/BoneAttachment3D/bone.can_dmg = value
