extends Node3D
@onready var animtree: AnimationTree = $AnimationTree

@onready var move_state = animtree.get("parameters/move/playback")
@onready var attack_state = animtree.get("parameters/attack/playback")
@onready var extra_anim = animtree.get_tree_root().get_node('xtra')
@onready var face_mat:StandardMaterial3D = $Rig/Skeleton3D/Godette_Head.get_surface_override_material(0)

var isattacking := false
var stretch := 1.0:
	set(value):
		stretch = value
		var negative = 1.0 + (1.0 - stretch)
		scale = Vector3(negative,stretch,negative)
const faces = {
	"default": Vector3.ZERO,
	'blink':Vector3(0,0.5,0)
}
var random_blin = RandomNumberGenerator.new()

func set_move_state(state_name:String) -> void:
	move_state.travel(state_name)



func attack_toggle(value:bool):
	isattacking= value


func AttackState() -> void:
	if not isattacking:
		attack_state.travel('Slice' if $slice.time_left else 'Chop')
		animtree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_dmg(value:bool):
	$Rig/Skeleton3D/RightHandSlot/Sword.can_dmg = value


func DefendState(forward:bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)
	
func _defend_change(value:float) -> void:
	animtree.set("parameters/Blend2/blend_amount", value)


func switch_weapon(weapon_active: bool) -> void:
	if weapon_active:
		$Rig/Skeleton3D/RightHandSlot/Sword.show()
		$Rig/Skeleton3D/RightHandSlot/wand2.hide()
	else:
		$Rig/Skeleton3D/RightHandSlot/Sword.hide()
		$Rig/Skeleton3D/RightHandSlot/wand2.show()


func cast_spell() -> void:
	extra_anim.animation = 'Spellcast_Shoot'
	if not isattacking:
		animtree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shoot_magic() -> void:
	get_parent().shoot_magic($Rig/Skeleton3D/RightHandSlot/wand2/wand/Marker3D.global_position)

func hit() ->void:
	extra_anim.animation = 'Hit_B'
	animtree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animtree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	isattacking = false
	var tween = create_tween()
	tween.tween_method(_hit_effect, 0.0,1.0,0.3)
	tween.tween_method(_hit_effect, 1.0,0.0,0.25)


func face_change(expression):
	face_mat.uv1_offset = faces[expression]

func _on_blink_timeout() -> void:
	face_change('blink')
	await get_tree().create_timer(0.2).timeout
	face_change('default')
	$blink.wait_time = random_blin.randf_range(1.5,3.0)
	

func heal_tween():
	var tween = create_tween()
	tween.tween_method(_heal_effect, 0.0,1.0,0.5)
	tween.tween_method(_heal_effect, 1.0,0.0,0.25)

func _heal_effect(val:float):
	$Rig/Skeleton3D/Godette_Head.material_overlay.set_shader_parameter("alpha", val)
	$Rig/Skeleton3D/Godette_Head.material_overlay.set_shader_parameter("color", Color.GREEN)

func _hit_effect(val:float):
	$Rig/Skeleton3D/Godette_Head.material_overlay.set_shader_parameter("alpha", val)
	$Rig/Skeleton3D/Godette_Head.material_overlay.set_shader_parameter("color", Color.DARK_RED)
