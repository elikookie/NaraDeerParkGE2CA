extends CharacterBody3D

@export var speed := randf_range(1.0, 2.5)
@export var gravity := 9.8

var move_direction: Vector3 = Vector3.ZERO
var change_timer := 0.0
var target_direction: Vector3 = Vector3.ZERO

func _ready():
	$AnimationPlayer.play("walk")
	choose_new_direction()

func _physics_process(delta):
	change_timer -= delta
	if change_timer <= 0:
		choose_new_direction()
	
	# Smooth interpolation toward the target direction
	move_direction = move_direction.lerp(target_direction, 0.05)
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta

	move_and_slide()
	
	# Check for collisions and turn around if hit something
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			# Reverse direction if hit
			target_direction = -move_direction.normalized()
			move_direction = target_direction
			change_timer = randf_range(1.0, 3.0)  # Pick a new direction soon
			break  # Only react to the first collision
		
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() > 0.1:
		var facing = global_position + horizontal_velocity.normalized()
		look_at(Vector3(facing.x, global_position.y, facing.z), Vector3.UP)
		rotate_y(PI)  # Flip 180 degrees to face forward
	
func choose_new_direction():
	# Pick a new random horizontal direction
	var angle = randf() * TAU  # 0 to 2π
	target_direction = Vector3(sin(angle), 0, cos(angle)).normalized()
	change_timer = randf_range(2.0, 5.0)  # New direction every 2–5 seconds
