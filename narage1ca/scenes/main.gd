extends Node3D
@export var deer_scene: PackedScene
@export var number_of_deer: int = 10

func spawn_deer():
	for i in range(number_of_deer):
		var deer_instance = deer_scene.instantiate()
		var x = randf_range(-10, 10)
		var z = randf_range(-10, 10)
		
		deer_instance.position = Vector3(x, 5, z)
		
		get_node("DeerContainer").add_child(deer_instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_deer()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
