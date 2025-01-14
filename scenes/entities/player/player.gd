extends CharacterBody3D
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var ui := $UI
@onready var godette := $GodetteSkin
@export var run_speed :float= 6.0
@export var base_speed :float = 4.0
@export var defend_speed :float= 2.0
@onready var particles_run = $Run
var speed_mod := 1.0
var weapon_active := true:
	set(value):
		weapon_active = value
		if weapon_active:
			ui.get_node("Spells").hide()
		else:
			ui.get_node("Spells").show()
var health:int = 5:
	set(value):
		ui.upd_health(value,value - health)
		health = value
		if health <0:
			get_tree().quit()
var energy = 100:
	set(value):
		energy = min(100, value)
		ui.upd_energy(energy)
var stamina = 100:
	set(value):
		ui.upd_stamina(stamina, value)
		if stamina == 100 and value < 100:
			ui.change_stamina_vis(1.0)
		if value == 100:
			ui.change_stamina_vis(0.0)
		stamina = clamp(value,0,100)
signal cast_spell(type:String, position:Vector3, direction:Vector2, size:float)

enum spells {FIREBALL, HEAL}
var current_spell = spells.FIREBALL
var movement_input = Vector2.ZERO
var last_movementinput = Vector2(0,1)
var defend: = false:
	set(value):
		if not defend and value:
			godette.DefendState(true)
		if defend and not value:
			godette.DefendState(false)
		defend = value
@onready var camera = $CameraController/Camera3D


func _ready() -> void:
	weapon_active = true
	godette.switch_weapon(weapon_active)
	ui.setup(health)

func _physics_process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("player_position", global_position)
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	move_and_slide()
	physics()


func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x,velocity.z) * speed_mod
	var is_running := Input.is_action_pressed("run")
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		vel_2d += movement_input * speed * delta * 8.0
		vel_2d = vel_2d.limit_length(speed)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		godette.set_move_state('Run')
		var target_angle = -movement_input.angle() + PI/2
		godette.rotation.y = rotate_toward(godette.rotation.y, target_angle, 6.0 * delta)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		godette.set_move_state('Idle')
	if movement_input:
		last_movementinput = movement_input.normalized()
		
	particles_run.emitting = is_running and is_on_floor() and movement_input != Vector2.ZERO
	if movement_input and is_on_floor():
		if not $walk.playing:
			$walk.playing = true
	else:
		$walk.playing = false
 
func jump_logic(delta:float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= 20:
			velocity.y = -jump_velocity
			do_stretch(1.2,0.15)
			stamina -= 20
	else:
		godette.set_move_state('Jump')
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

func ability_logic() -> void:
	
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			godette.AttackState()
			$sword.play()
		else:
			if energy >= 20:
				godette.cast_spell()
				stop_movement(0.3,0.8)
	defend = Input.is_action_pressed("block")
	
	if Input.is_action_just_pressed("switch weapon")and not godette.isattacking:
		weapon_active = not weapon_active
		godette.switch_weapon(weapon_active)
		do_stretch(1.05,0.15)
	if Input.is_action_just_pressed("switch spell") and not godette.isattacking:
		current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		ui.upd_spell(spells, current_spell)

func stop_movement(start:float, end:float):
	var tween = create_tween()
	tween.tween_property(self, "speed_mod", 0.0, start)
	tween.tween_property(self, "speed_mod", 1.0, end)

func hit() -> void:
	if not $invul.time_left:
		godette.hit()
		stop_movement(0.3,0.3)
		health -= 1
		$invul.start()

func do_stretch(val:float, dur:float = 0.1):
	var tween = create_tween()
	tween.tween_property(godette, "stretch", val,dur).set_ease(Tween.EASE_IN)
	tween.tween_property(godette, "stretch", 1.0,dur * 1.8).set_ease(Tween.EASE_IN_OUT)

func shoot_magic(pos:Vector3) -> void:
	if current_spell == spells.FIREBALL:
		cast_spell.emit("fireball", pos, last_movementinput,1.0)
		energy -= 20
	if current_spell == spells.HEAL:
		health += 1
		energy -= 30
		godette.heal_tween()

func _on_energyrecov_timeout() -> void:
	energy += 1

func _on_timer_timeout() -> void:
	stamina += 1


func physics():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-get_slide_collision(i).get_normal())
		
