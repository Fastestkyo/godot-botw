class_name Enemy
extends CharacterBody3D
@warning_ignore("unused_signal")
signal cast_spell(type:String, position:Vector3, direction:Vector2, size:float)
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_anim = $AnimationTree.get_tree_root().get_node('AttackAnimation')
@onready var player = get_tree().get_first_node_in_group('Player')
@onready var skin = get_node('skin')
@export var walk_speed :float = 2.0
@export var speed = walk_speed
@export var notice_radius := 30.0
@export var attack_radius := 3.0
var health :=5:
	set(value):
		health = value
		if health <= 0:
			queue_free()
var stretch := 1.0:
	set(value):
		stretch = value
		var negative = 1.0 + (1.0 - stretch)
		skin.scale = Vector3(negative,stretch,negative)
var speed_mod := 1.0
var rng = RandomNumberGenerator.new()
func move_to_player(delta):
	if position.distance_to(player.position) < notice_radius:
		var target_dir = (player.position - position).normalized()
		var target_vec2 = Vector2(target_dir.x, target_dir.z)
		var target_angle = -target_vec2.angle() + PI/2
		rotation.y = rotate_toward(rotation.y, target_angle, delta * 6.0) 
		if position.distance_to(player.position) > attack_radius:
			velocity = Vector3(target_vec2.x,0, target_vec2.y) * speed * speed_mod
			move_state_machine.travel("walk")
		else:
			velocity = Vector3.ZERO
			move_state_machine.travel("idle")
		
		if !is_on_floor():
			velocity.y -=2
		else:
			velocity.y = 0
		move_and_slide()

func stop_movement(start_duration:float,end_duration:float):
	var tween = create_tween()
	tween.tween_property(self, "speed_mod", 0.0, start_duration)
	tween.tween_property(self, "speed_mod", 1.0, end_duration)
	
func do_stretch(val:float, dur:float = 0.1):
	var tween = create_tween()
	tween.tween_property(self, "stretch", val,dur).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "stretch", 1.0,dur * 1.8).set_ease(Tween.EASE_OUT)
	
func hit() ->void:
	if not $Timers/hit_Timer.time_left:
		$Timers/hit_Timer.start()
		do_stretch(1.2,0.15)
		health -= 1
