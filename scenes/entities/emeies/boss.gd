extends Enemy
var spinning :=false
@export var spin_speed = 6
const simple_attacks = {
	'slice': "2H_Melee_Attack_Slice",
	'spin': "2H_Melee_Attack_Spin",
	'range': "2H_Melee_Attack_Stab",
}
var can_dmg_tgl := false
func _physics_process(delta: float) -> void:
	move_to_player(delta)
func _process(_delta: float) -> void:
	attack_logic()

func _on_timer_timeout() -> void:
	$Timers/Timer.wait_time = rng.randf_range(4.0,5.5)
	if position.distance_to(player.position) < 5.0:
		melee_attack_animation()
	else:
		if rng.randi() % 2:
			range_attack_animation()
		else:
			spin_attack_animation()


func melee_attack_animation():	
	attack_anim.animation = simple_attacks['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func range_attack_animation() -> void:
	stop_movement(1.6,1.6)
	attack_anim.animation = simple_attacks['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	
func shoot_fireball() -> void:
	var dir = (player.position - position).normalized()
	var dir2d = Vector2(dir.x,dir.z)
	var pos = $skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/Marker3D.global_position
	cast_spell.emit("fireball", pos, dir2d,3.0)

	
func spin_attack_animation():
	var tween = create_tween()
	tween.tween_property(self, "speed", spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0,1.0,0.3)
	$Timers/Timer.stop()
	spinning = true
	can_dmg_tgl = true

func _spin_transition(value:float):
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if spinning:
		await get_tree().create_timer(rng.randf_range(1.0,2.0)).timeout
		var tween = create_tween()
		tween.tween_property(self, "speed", walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0,0.0,0.3)
		spinning = false
		$Timers/Timer.start()
		can_dmg_tgl = false

func hit():
	if not $Timers/hit_Timer.time_left:
		$Timers/hit_Timer.start()
		health -= 1
		var tween = create_tween()
		tween.tween_method(_hit_effect, 0.0,0.5,0.3)
		tween.tween_method(_hit_effect, 0.5,0.0,0.15)
func _hit_effect(val:float):
	$skin/Rig/Skeleton3D/Nagonford_Body.material_overlay.set_shader_parameter("alpha", val)

func can_dmg(value:bool) -> void:
	can_dmg_tgl = value
	
func attack_logic() -> void:
	if can_dmg_tgl:
		var collision = $skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/RayCast3D.get_collider()
		if collision and "hit" in collision:
			collision.hit()
