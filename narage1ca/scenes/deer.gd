extends CharacterBody3D

@export var min_speed: float = 0.2
@export var max_speed: float = 1.5
@export var turn_speed: float = 2   # radians per second

var gravity := 9.8

@onready var anim_player:   AnimationPlayer = $AnimationPlayer
@onready var dir_timer:     Timer           = $DirectionTimer
@onready var obstacle_ray:  RayCast3D       = $ObstacleRay

var speed:      float
var move_dir:   Vector3 = Vector3.ZERO
var state:      String  = "wander"
var target_dir: Vector3 = Vector3.ZERO
var target_yaw: float   = 0.0

func _ready() -> void:
	randomize()
	speed = randf_range(min_speed, max_speed)
	anim_player.play("walk")

	# set up the wander timer
	dir_timer.one_shot = false
	dir_timer.timeout.connect(_on_dir_timer_timeout)
	_on_dir_timer_timeout()
	dir_timer.start()

	obstacle_ray.enabled = true

func _physics_process(delta: float) -> void:
	# 1) gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match state:
		"wander":
			# if we see a wall, switch to turning
			if obstacle_ray.is_colliding():
				_start_turn(-move_dir)
			_wander(delta)

		"turning":
			_do_smooth_turn(delta)

	move_and_slide()

func _wander(delta: float) -> void:
	# Simple forward movement
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	# Smoothly rotate towards movement direction
	var horiz = Vector3(velocity.x, 0, velocity.z)
	if horiz.length() > 0.1:
		# Calculate the desired look rotation
		var target_rotation = global_transform.looking_at(global_position + horiz.normalized(), Vector3.UP)
		var current_basis = global_transform.basis
		var target_basis = target_rotation.basis

		# Fix for forward direction (rotate 180 around Y)
		target_basis = target_basis.rotated(Vector3.UP, PI)

		# Interpolate
		var current_quat = Quaternion(current_basis)
		var target_quat = Quaternion(target_basis)
		var interpolated_quat = current_quat.slerp(target_quat, turn_speed * delta)

		global_transform.basis = Basis(interpolated_quat)

func _start_turn(new_dir: Vector3) -> void:
	state = "turning"
	target_dir = new_dir.normalized()
	target_yaw = atan2(target_dir.x, target_dir.z)

	# stop movement
	velocity.x = 0
	velocity.z = 0

	# delay next random direction change until after turn
	dir_timer.start(randf_range(1.0, 2.0))

func _do_smooth_turn(delta: float) -> void:
	var current_yaw = rotation.y
	var diff = wrapf(target_yaw - current_yaw, -PI, PI)
	var step = turn_speed * delta

	if abs(diff) <= step:
		rotation.y = target_yaw
		# done turning!
		state = "wander"
		move_dir = target_dir
		anim_player.play("walk")
		return

	# otherwise rotate partway toward target
	rotation.y += sign(diff) * step

func _on_dir_timer_timeout() -> void:
	# pick a brand-new heading every 2–5s, but only when wandering
	if state == "wander":
		dir_timer.wait_time = randf_range(10.0, 15.0)
		var ang = randf() * TAU
		move_dir = Vector3(cos(ang), 0, sin(ang)).normalized()
