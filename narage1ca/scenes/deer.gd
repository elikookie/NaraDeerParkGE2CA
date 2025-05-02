extends CharacterBody3D

@export var min_speed: float = 0.1
@export var max_speed: float = 1
@export var turn_speed: float = 2.0
@export var gravity: float = 9.8

@onready var anim_player = $AnimationPlayer
@onready var obstacle_ray = $ObstacleRay
@onready var dir_timer = $DirectionTimer
@onready var graze_timer = $GrazeTimer

var speed: float
var move_dir: Vector3 = Vector3.ZERO
var target_dir: Vector3 = Vector3.ZERO
var target_yaw: float = 0.0
var state: String = "wander"

func _ready():
	randomize()
	speed = randf_range(min_speed, max_speed)
	start_wander()

	dir_timer.timeout.connect(_on_direction_timeout)
	graze_timer.timeout.connect(_on_graze_timeout)

	dir_timer.start()
	obstacle_ray.enabled = true

func _physics_process(delta: float):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match state:
		"wander":
			if obstacle_ray.is_colliding():
				start_turn(-move_dir)
			else:
				velocity.x = move_dir.x * speed
				velocity.z = move_dir.z * speed
				rotate_toward_direction(delta)

		"turning":
			do_smooth_turn(delta)

		"graze":
			velocity.x = 0
			velocity.z = 0

	move_and_slide()

func _on_direction_timeout():
	if state == "wander":
		if randf() < 0.1:
			start_graze()
		else:
			pick_new_direction()
			dir_timer.start(randf_range(10.0, 15.0))

func start_wander():
	state = "wander"
	anim_player.play("walk")
	pick_new_direction()
	dir_timer.start(randf_range(10.0, 15.0))

func pick_new_direction():
	var ang = randf() * TAU
	move_dir = Vector3(cos(ang), 0, sin(ang)).normalized()

func start_graze():
	state = "graze"
	anim_player.play("eat")
	dir_timer.stop()
	graze_timer.start(6.0)  # 5 seconds graze

func _on_graze_timeout():
	start_wander()

func start_turn(dir: Vector3):
	state = "turning"
	target_dir = dir.normalized()
	target_yaw = atan2(target_dir.x, target_dir.z)

	velocity.x = 0
	velocity.z = 0
	dir_timer.stop()

func do_smooth_turn(delta: float):
	var current_yaw = rotation.y
	var diff = wrapf(target_yaw - current_yaw, -PI, PI)
	var step = turn_speed * delta

	if abs(diff) <= step:
		rotation.y = target_yaw
		move_dir = target_dir
		start_wander()
	else:
		rotation.y += sign(diff) * step

func rotate_toward_direction(delta: float):
	var horiz = Vector3(velocity.x, 0, velocity.z)
	if horiz.length() > 0.1:
		var target = global_transform.looking_at(global_position + horiz.normalized(), Vector3.UP)
		var target_basis = target.basis.rotated(Vector3.UP, PI)  # flip model
		global_transform.basis = global_transform.basis.slerp(target_basis, turn_speed * delta)
