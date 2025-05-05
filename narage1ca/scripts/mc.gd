extends CharacterBody3D
class_name Player


@export_subgroup("Movement")
@export var speed = 8.0
@export var accel = 16.0
@export var jump = 8.0

@export_subgroup("Camera")
@export var sensitivity = 0.2
@export var min_angle = -80
@export var max_angle = 90

@onready var head = $Head
@onready var collision_shape = $CollisionShape3D
@onready var top_cast = $TopCast
@onready var ui = $UI

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var stand_height : float
var old_vel : float = 0.0
var moving : bool = true

func _ready():
	add_to_group("player")
	look_rot.y = rotation_degrees.y
	stand_height = collision_shape.shape.height
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		pass
	# movement
	var move_speed = speed
	
	if Input.is_action_just_pressed("interact"):
		for deer in get_tree().get_nodes_in_group("deer"):
			var distance = global_position.distance_to(deer.global_position)
			var forward = -deer.global_transform.basis.z.normalized()
			var to_player = (global_position - deer.global_position).normalized()

			if distance < deer.bow_distance and forward.dot(to_player) > 0.7 and GameState.get_value("cookie") > 0:
						# Feed one deer...
						GameState.set_value("cookie", GameState.get_value("cookie") - 1)
						# **all** hungry deer if out of cookies:
						if GameState.get_value("cookie") <= 0:
							for d in get_tree().get_nodes_in_group("deer"):
								if d.state == "hungry":
									d.start_wander()

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif moving:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and moving:
		velocity.x = lerp(velocity.x, direction.x * move_speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)

	move_and_slide()
	
	# rotation
	var plat_rot = get_platform_angular_velocity()
	look_rot.y += rad_to_deg(plat_rot.y * delta)
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y
	


func _input(event):
	if event is InputEventMouseMotion and moving:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
