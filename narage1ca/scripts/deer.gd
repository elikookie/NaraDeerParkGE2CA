extends CharacterBody3D

@export var min_speed: float = 0.3
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
var is_flock_leader: bool = false
var flock_leader: Node3D = null
var flock_timer: float = 0.0
var is_turning_in_place := false
var player: Node3D = null
var hunger_range: float = 10.0
var bow_distance: float = 3.0
var is_bowing: bool = false

func _ready():
	randomize()
	speed = randf_range(min_speed, max_speed)
	start_wander()
	add_to_group("deer")
	
	dir_timer.timeout.connect(_on_direction_timeout)
	graze_timer.timeout.connect(_on_graze_timeout)

	player = get_tree().get_nodes_in_group("player")[0]

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
			if player and GameState.get_value("cookie") > 0:
				var distance = global_position.distance_to(player.global_position)
				if distance < hunger_range:
					start_hungry()
					return
			elif obstacle_ray.is_colliding():
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
		"flock":
			if flock_leader:
				var to_leader = (flock_leader.global_position - global_position).normalized()
				move_dir = move_dir.lerp(to_leader, 0.1)
				velocity.x = move_dir.x * speed
				velocity.z = move_dir.z * speed
				rotate_toward_direction(delta)

				flock_timer -= delta
				if flock_timer <= 0.0:
					flock_leader = null
					start_wander()
			else:
				start_wander()
		"hungry":
			if GameState.get_value("cookie") <= 0:
				start_wander()
				return
			if player:
				var to_player = (player.global_position - global_position).normalized()
				var distance = global_position.distance_to(player.global_position)
				if distance > bow_distance:
					move_dir = move_dir.lerp(to_player, 0.1)
					velocity.x = move_dir.x * speed
					velocity.z = move_dir.z * speed
					rotate_toward_direction(delta)
				else:
					# stop and bow
					velocity.x = 0
					velocity.z = 0
					if not is_bowing:
						anim_player.play("bow")
						is_bowing = true

	move_and_slide()

func _on_direction_timeout():
	if state != "wander":
		return
	
	# 20% chance to graze
	if randf() < 0.2:
		start_graze()
		return

	# 10% chance to start flock
	if randf() < 0.1:
		become_flock_leader()
		return

	# otherwise just change direction
	pick_new_direction()
	dir_timer.start(randf_range(5.0, 8.0))
	
func start_wander():
	state = "wander"
	anim_player.play("walk")
	pick_new_direction()
	dir_timer.start(randf_range(10.0, 15.0))
	is_bowing = false
	
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

func start_flock(leader: Node3D):
	state = "flock"
	flock_leader = leader
	anim_player.play("walk")
	flock_timer = 15.0
	print_debug("Flocking")

func become_flock_leader():
	is_flock_leader = true
	pick_new_direction()
	state = "wander"
	anim_player.play("walk")
	dir_timer.start(randf_range(5.0, 8.0))

	# Look for nearby deer in scene
	var nearby_deer = []
	for deer in get_parent().get_children():
		if deer != self and deer is CharacterBody3D:
			if global_position.distance_to(deer.global_position) < 10.0 and randf() < 0.5:
				nearby_deer.append(deer)
	
	# Start flocking on 2-4 others
	for d in nearby_deer.slice(0, 4):
		d.start_flock(self)
	
func start_turn(dir: Vector3):
	state = "turning"
	target_dir = dir.normalized()
	target_yaw = atan2(target_dir.x, target_dir.z)

	velocity.x = 0
	velocity.z = 0
	dir_timer.stop()

func do_smooth_turn(delta: float):
	var desired_dir = target_dir.normalized()
	var facing_target = global_transform.looking_at(global_position + desired_dir, Vector3.UP)
	var target_basis = facing_target.basis

	var current_quat = global_transform.basis.get_rotation_quaternion()
	var target_quat = target_basis.get_rotation_quaternion()

	var smooth_quat = current_quat.slerp(target_quat, turn_speed * delta)

	global_transform.basis = Basis(smooth_quat)

	# Check if we're done turning
	if current_quat.dot(target_quat) > 0.999:
		move_dir = desired_dir
		start_wander()

func rotate_toward_direction(delta: float):
	var horiz = Vector3(velocity.x, 0, velocity.z)
	if horiz.length() > 0.1:
		var target = global_transform.looking_at(global_position + horiz.normalized(), Vector3.UP)
		var target_basis = target.basis

		var current_quat = global_transform.basis.get_rotation_quaternion()
		var target_quat = target_basis.get_rotation_quaternion()

		var smooth_quat = current_quat.slerp(target_quat, turn_speed * delta)
		global_transform.basis = Basis(smooth_quat)

func start_hungry():
	state = "hungry"
	anim_player.play("walk")
	dir_timer.stop()
	graze_timer.stop()
	is_bowing = false
