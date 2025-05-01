extends CharacterBody3D

@export var min_speed: float = 1.0
@export var max_speed: float = 2.5

var gravity := 9.8

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var dir_timer: Timer = $DirectionTimer

var speed: float
var move_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	randomize()
	speed = randf_range(min_speed, max_speed)
	anim_player.play("walk")

	# Configure and start our direction‐change timer
	dir_timer.one_shot = false
	dir_timer.wait_time = randf_range(2.0, 5.0)
	dir_timer.start()
	dir_timer.timeout.connect(_on_dir_timer_timeout)

	_on_dir_timer_timeout()

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# move
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	move_and_slide()

	# rotate to face movement
	var horiz_vel = Vector3(velocity.x, 0.0, velocity.z)
	if horiz_vel.length() > 0.1:
		look_at(global_position + horiz_vel.normalized(), Vector3.UP)
		rotate_y(PI)

func _on_dir_timer_timeout() -> void:
	# Every 2–5s this picks a new random heading
	dir_timer.wait_time = randf_range(2.0, 5.0)
	var angle = randf() * TAU
	move_dir = Vector3(cos(angle), 0.0, sin(angle))
